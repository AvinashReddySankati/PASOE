#!/bin/sh
# A monitoring tool. Uses jmx services to access Tomcat beans:
#  - generates a list of bean operations and attributes exposed to jmx
#  - invokes bean operations and reads bean attributes.
# Accepts four optional attributes
# -C - signals to generate a list of bean operations/attributes 
# -Q <query parameter> -
#    query parameter could be either a path to a file with a set of JMX queries or a single JMX query 
#    Find example JMX queries file default.qry in <CATALINA_BASE>\bin\jmxqueries directory
#    A single JMX query is a JSON string like in default.qry with escaped quote and curly bracket characters. For example:
#         \{\"O\":\"PASOE:type=OEManager,name=AgentManager\",\"M\":[\"getAgents\",\"oepas1\"]\}
#    This parameter is ignored if -C attribute present. Default value: <PASOE Base Dir>/bin/queries/queries.txt.   
# -O [<file name>] - output file name (with path). 
#    If no file name provided then the output directed to the console
#    The file name may include timestamp template: {TIMESTAMP} or {TIMESTAMP:<java type datetime format>}
#    Default values if no -O key used:
#      If -C argument presents: <PASOE Temp Dir>/beanInfo{TIMESTAMP:yyMMdd-HHmm}.txt
#      If no -C argument:  <PASOE Temp Dir>/queries-out-{TIMESTAMP:yyMMdd-HHmmss}.txt
#    This parameter is ignored if a single JMX query used
# -R - signals write into output file results only. Otherwise output file also includes query texts. 
#    Ignored if -C argument is present or a single JMX query used
# Get the script directory

# Function to extract all propertis form  localJvm.properties
# set _jvmArgs value
getJvmScriptProperities() {
    _propfile="${pasoebase}/conf/localJvm.properties"
    _jvmArgs=""
    if [[ -f $_propfile ]] ; then
        while IFS= read -r _line
        do
            # display line or do somthing on $line
            _nline=`echo $_line | sed 's/ *$//g'`
            if ! [[ $_nline == "#"* ]] ; then 
            _jvmArgs="$_jvmArgs $_nline"
            fi
        done <"$_propfile"
    fi
}

dbg=""
javahome=""
tmpdir=""
pasoepid=""
pasoehome=""
pasoebase=""
beanInfo=""
resultOnly=""
resultOnlyArg=""
queriesArg=""
jacksoncore=""
jacksonmapper=""
oejmx=""
qResults=""
queryFile=""
queryJSON=""

scriptPath=`dirname $0`
if [ ! "$dbg" = "" ]; then
	echo "scriptPath:  $scriptPath"
fi

#get environment parameters using tcman.sh 
envVars=`exec sh $scriptPath/tcman.sh env  javahome tmpdir pid home base`
envVars=`echo "$envVars" |  tr "\n" " "`

for val in  $envVars; do
if [ "$javahome" = "" ]; then	javahome="$val";   else
if [ "$tmpdir" = "" ]; then 	tmpdir="$val";  else
if [ "$pasoepid" = "" ]; then 	pasoepid="$val"; else
if [ "$pasoehome" = "" ]; then 	pasoehome="$val"; else
 pasoebase="$val";  
fi  fi  fi fi	
done
if [ ! "$dbg" = "" ]; then
	echo "javahome: $javahome"
	echo "tmpdir: $tmpdir"
	echo "pasoepid: $pasoepid"
	echo "pasoehome: $pasoehome"
fi

# Check is server is running
lifecycle="$tmpdir/*.lifecycle"
if [ ! -f $lifecycle ]; then
    echo "Error! Cannot find lifecycle file in temp dir. Is the server running?";
    exit 1;
fi

# Get parameters
qResults=$tmpdir
queriesArg=""
parg=""
arg=""
known=""
while [ $# -gt 0 ]
do
  if [ "$1" = "-R" ]; then  resultOnlyArg="-R"; arg=$1; known="1"; fi
  if [ "$1" = "-C" ]; then  beanInfo="-C";  arg=$1; known="1"; fi
  if [ "$1" = "-Q" ]; then  arg=$1; known="1"; fi 
  if [ "$1" = "-O" ]; then  arg=$1; qResults="@"; known="1"; fi 

  if [ "$arg" = "" ]; then 
    if [ "$parg" = "-O" ]; then qResults=$1; known="1"; fi 
    if [ "$parg" = "-Q" ]; then queriesArg=$1; known="1"; fi 
  fi
  if [ "$known" = "" ]; then
     echo "Error! Unknown parameter $1"
     exit 1
  fi   
  parg=$arg
  arg=""
  known=""
  shift
done

if [ ! "$dbg" = "" ]; then
	echo "beanInfo:   $beanInfo"
	echo "resultOnlyArg: $resultOnlyArg"
	echo "queriesArg:    $queriesArg"
	echo "qResults:   $qResults"
fi

# validate jar file presents 
commonLib="$pasoehome/common/lib"
jacksonJars=`ls $commonLib/jackson-*-asl-[0-9\.]*\.jar`
jacksonJars=`echo "$jacksonJars" |  tr "\n" " "`

for ff in  $jacksonJars; do
  nn=`expr match "$ff" ".*jackson-core-asl.*"` 
  if [ ! "$nn" = "0" ]; then jacksoncore=$ff; else
  nn=`expr match "$ff" ".*jackson-mapper-asl.*"` 
  if [ ! "$nn" = "0" ]; then jacksonmapper=$ff; 
  fi fi
done 

if [ "$jacksoncore" = "" ] ; then
	echo "Error! Can't find jackson-core-asl*.jar in directory $commonLib";
	exit 1
fi
if [ "$jacksonmapper" = "" ] ; then
	echo "Error! Can't find jackson-mapper-asl*.jar in directory $commonLib";
	exit 1
fi


# find oejmx jar
binDir="$pasoehome/bin"
oejmxJars=`ls $binDir/oejmx-[0-9\.]*\.jar`
oejmxJars=`echo "$oejmxJars" |  tr "\n" " "`

for ff in  $oejmxJars; do
  oejmx=$ff 
done 

if [ "$oejmx" = "" ] ; then
	echo "Error! Can't find oejmx*.jar in directory $binDir";
	exit 1
fi

# check queries file
if [ "$beanInfo" = "" ]; then
if [ "$queriesArg" = "" ]; then 
	queryFile="$scriptPath/jmxqueries/default.qry"
else
    first=`echo "$queriesArg" | cut -c1`
    if [ "$first" = "{" ]; then
        queryJSON="$queriesArg"
    else
        queryFile="$queriesArg"
    fi
fi
resultOnly="$resultOnlyArg"
if [ ! "$queryFile" = "" ]; then
if [ ! -f "$queryFile" ]; then
     echo "Error! Cannot find queries file  '$queryFile'"
     exit 1 
fi
fi
fi

# get $_jvmArgs
_jvmArgs=""
getJvmScriptProperities 
#echo "JAVA ARGS: $_jvmArgs"


# run jmx query
pasoeJmxCall="$javahome/bin/java" 
pasoeJmxCallCp="-cp $jacksoncore:$jacksonmapper:$oejmx"

if [ ! "$queryFile" = "" ]; then
    pasoeJmxCallClass="com.progress.appserv.util.jmx.PASOEWatch" 
    command="$pasoeJmxCall $_jvmArgs $pasoeJmxCallCp $pasoeJmxCallClass $pasoepid $queryFile $qResults $resultOnly $beanInfo"
    if [ ! "$dbg" = "" ]; then
        echo "COMMAND: $command"
    fi
    eval "$command"
fi
if [ ! "$beanInfo" = "" ]; then
    pasoeJmxCallClass="com.progress.appserv.util.jmx.PASOEWatch" 
    command="$pasoeJmxCall $_jvmArgs $pasoeJmxCallCp $pasoeJmxCallClass $pasoepid $queryFile $qResults $resultOnly $beanInfo"
    if [ ! "$dbg" = "" ]; then
        echo "COMMAND: $command"
    fi
    eval "$command"
fi
if [ ! "$queryJSON" = "" ]; then
    pasoeJmxCallClass="com.progress.appserv.util.jmx.JmxQuery" 
    command="$pasoeJmxCall $_jvmArgs $pasoeJmxCallCp $pasoeJmxCallClass $pasoepid $queryJSON"
    if [ ! "$dbg" = "" ]; then
        echo "COMMAND: $command"
    fi
    ret=`$command`
    echo "$ret"
fi

