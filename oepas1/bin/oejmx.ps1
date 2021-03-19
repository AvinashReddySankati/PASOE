#finction to read jvm argumets
function readJvmProps($propFilePath)  {
    $jvmArgs = "";
    if ([System.IO.File]::Exists($propFilePath)) {
        foreach($line in (Get-Content $propFilePath)){
        $line = $line.trim()
            if (!$line.StartsWith("#")) {
                $jvmArgs += " "
                $jvmArgs += $line
            }
        }
    } 
    return $jvmArgs
}
#function to run a program
function runCommand($arg0, $arg1) {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $arg0
    $startInfo.Arguments = $arg1
    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false
    #$startInfo.CreateNoWindow = $false

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $result = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()
    return $result
}

# Get environment attributes:
$dbg=""
$javahome=""
$tmpdir=""
$pasoepid=""
$pasoehome=""
$pasoebase=""
$beanInfo=""
$resultOnly=""
$queriesArg=""
$resultOnlyArg=""
$jacksoncore=""
$jacksonmapper=""
$oejmx=""
$qResults=""
$queryFile=""
$queryJSON=""

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
if ($dbg -ne "")  {
	write-output "scriptPath:  $scriptPath"
}
$Result = &  "$scriptPath\tcman.bat" env javahome tmpdir pid home base
$ii = 0
foreach ($s in $Result)
{
    if (!$s.StartsWith("debug: ")) {
        if ($ii -eq 0) {$javahome = $s}
        if ($ii -eq 1) {$tmpdir = $s}
        if ($ii -eq 2) {$pasoepid = $s}
        if ($ii -eq 3) {$pasoehome = $s}
        if ($ii -eq 4) {$pasoebase = $s}
        $ii += 1
    }
	
}
if ($dbg -ne "")  {
    write-output "javahome: $javahome" "tmpdir: $tmpdir" "pasoepid: $pasoepid" "pasoehome: $pasoehome" "pasoebase: $pasoebase"
}

#check if server is running
$lifecycle="$tmpdir\*.lifecycle";
if ( !(test-path $lifecycle)) {
    write-error "Error! Cannot find lifecycle file in temp dir. Is the server running?"
    exit 1
}

#Get Arguments
if ($dbg -ne "")  {
    write-output "arguments: $args"
}

$qResults=$tmpdir
$queriesArg=""
$parg=""
$arg=""
$known=""

$argNum = 0;
while ($argNum -lt $args.length)
{
  $key = $args[$argNum]
  if($key -eq "-R") {
	$resultOnlyArg = "-R"
    $arg = $key
    $known = "1"
  }
  if($key -eq "-C") {
	$beanInfo = "-C"
    $arg = $key
    $known = "1"
  }
  if($key -eq "-Q") {
    $arg = $key
    $known = "1"
  }
  if($key -eq "-O") {
    $arg = $key
    $known = "1"
    $qResults = "@"
  }
  if($arg -eq "") {
    if ($parg -eq "-O") {
        $qResults = $key
        $known="1"
    }
    if ($parg -eq "-Q") {
        $queriesArg = $key
        $known="1"
    }
  }
  if ($known -eq "" ) {
     write-error "Unknown parameter: $key"
     exit 1
  }
  $parg=$arg
  $arg=""
  $known=""
  $argNum++;  
}

if ($dbg -ne "")  {
    write-output "resultOnlyArg: $resultOnlyArg" "beanInfo: $beanInfo" "queriesArg: $queriesArg" "qResults: $qResults"
}



	
#Find and check jars
$commonLib = "$pasoehome\common\lib"
$jacksonjars = "$commonLib\jackson*.jar"

$jacksonCoreNoVersion = "jackson-core-asl-"
$jacksonMapperNoVersion = "jackson-mapper-asl-"
 

[string]$jacksonjarsArr = gci  $jacksonjars -name

if($jacksonjarsArr -ne "" -and $jacksonjarsArr -ne $null) { 
	$jacksonjarsArr.split(" ") | foreach {
	   $nn = $_
	   $re = $nn -replace "[0-9\.]*\.jar" 
	   if ($re -eq $jacksonCoreNoVersion) {
		  $jacksoncore = "$commonLib\$nn"
	   } else {if ($re -eq $jacksonMapperNoVersion) {
		  $jacksonmapper = "$commonLib\$nn"
	   }}
	}
}

if($jacksoncore -eq "") {
   write-error "Error! Cannot find  $jacksonCoreNoVersion*.jar"
   exit 1
}
if($jacksonmapper -eq "") {
   write-error "Error! Cannot find  $jacksonMapperNoVersion*.jar"
   exit 1
}

$binDir = "$pasoehome\bin"
$oejmxjar =  "$binDir\oejmx*jar"

$oejmxNoVersion = "oejmx"
[string]$oejmxjarArr = gci $oejmxjar -name

if($oejmxjarArr -ne $null -and $oejmxjarArr -ne "") { 
	$oejmxjarArr.split(" ") | foreach {	   
	   $dd = $_
	   $re = $dd -replace "-[0-9\.]*\.jar" 
	   if ($re -eq $oejmxNoVersion) {
		  $oejmx = "$binDir\$dd"
	   }
	}
}
if($oejmx -eq "") {
   write-error "Error! Cannot find  $binDir\$oejmxNoVersion*.jar"
   exit 1
}
# Set and check queries file if not -C
if($beanInfo -eq "") {
	if($queriesArg -eq "") {
		$queryFile = "$scriptPath\jmxqueries\default.qry"
	} else {
        if($queriesArg.Substring(0,1) -eq  "{") {
            $queryJSON =  $queriesArg   
        } else {       
            $queryFile = $queriesArg
        }
	}
	if( $queryFile -ne "" -and ![System.IO.File]::Exists("$queryFile")){
		 write-error "Error! Cannot find query file  ""$queries"""
		 exit 1 
	}
	$resultOnly=$resultOnlyArg
}

# Compose java command  
$pasoeJmxCall = "$javahome\bin\java.exe" 
$pasoeJmxCallCp = "-cp ""$jacksoncore"";""$jacksonmapper"";""$oejmx"""
$jvmArgs = readJvmProps "$pasoebase\conf\localJvm.properties"

if ($dbg -ne "")  {
	write-output "Command: $pasoeJmxCall $jvmArgs -cp ""$oejmx"";""$jacksonmapper"";""$jacksoncore""  $pasoeJmxCallClass $pasoepid $queryFile $qResults $resultOnly $beanInfo"
}
# Run jmx request
if ($queryJSON -ne "") {
    $pasoeJmxCallClass = "com.progress.appserv.util.jmx.JmxQuery"     
    $queryJSON = $queryJSON.Replace('"','"""')
    $queryJSON = $queryJSON.Replace('\"""','\\"""')     
    $arguments = "$jvmArgs -cp ""$oejmx"";""$jacksonmapper"";""$jacksoncore"" $pasoeJmxCallClass $pasoepid $queryJSON"
    #$result = & $pasoeJmxCall  -cp """$oejmx"";""$jacksonmapper"";""$jacksoncore""" $pasoeJmxCallClass $pasoepid $queryJSON 2>&1 | Out-String
    $result = runCommand $pasoeJmxCall $arguments
    write-output $result
} else {
    $pasoeJmxCallClass = "com.progress.appserv.util.jmx.PASOEWatch" 
    $arguments = "$jvmArgs -cp ""$oejmx"";""$jacksonmapper"";""$jacksoncore"" $pasoeJmxCallClass $pasoepid $queryFile $qResults $resultOnly $beanInfo"
    runCommand $pasoeJmxCall $arguments
    
  

} 

# SIG # Begin signature block
# MIIXvAYJKoZIhvcNAQcCoIIXrTCCF6kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdQ4y9Es3wg226CKQhw6Ydcre
# g7ugghLqMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTwMIID2KADAgECAhBjSQdkwGErmEN7894IOynRMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTIwMDExNTAwMDAwMFoX
# DTIxMDExNTIzNTk1OVowgYcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIDA1NYXNzYWNo
# dXNldHRzMRAwDgYDVQQHDAdCZWRmb3JkMSYwJAYDVQQKDB1Qcm9ncmVzcyBTb2Z0
# d2FyZSBDb3Jwb3JhdGlvbjEmMCQGA1UEAwwdUHJvZ3Jlc3MgU29mdHdhcmUgQ29y
# cG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDWtspXfpQ5
# Mr2tFfrVpJA4Fof8yWGT/3Nqwz43SOt3c75cHG71YfX7rqnEy8nZocxH77gNmZaE
# IVdU51Vl7oVG3GtBZjGh2YVjF6rpiaxp2yqcaYMxTLME6eCvM6cz+nKET8DaMPwq
# sEAvRsKrWhBFdGBDoV2KfTdDF5u3wVCieIzzkBCSErK5Bse7BUGX8sZPocjqThEg
# 0Vz4tPurvymCkPJ1VTSquenZ5oP7wJc5lZk3RVxeuW3b7WLlOZ3oQENn8OaOjTWk
# ZvsGRzhmcKzENz9oJWkYDfwchTv1SSYlVI6aa4QIojY46gAmVJmAb2IyEJ8bIgPO
# qEYUYGQZTsbNAgMBAAGjggFdMIIBWTAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIH
# gDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8vc3Yuc3ltY2IuY29tL3N2LmNybDBh
# BgNVHSAEWjBYMFYGBmeBDAEEATBMMCMGCCsGAQUFBwIBFhdodHRwczovL2Quc3lt
# Y2IuY29tL2NwczAlBggrBgEFBQcCAjAZDBdodHRwczovL2Quc3ltY2IuY29tL3Jw
# YTATBgNVHSUEDDAKBggrBgEFBQcDAzBXBggrBgEFBQcBAQRLMEkwHwYIKwYBBQUH
# MAGGE2h0dHA6Ly9zdi5zeW1jZC5jb20wJgYIKwYBBQUHMAKGGmh0dHA6Ly9zdi5z
# eW1jYi5jb20vc3YuY3J0MB8GA1UdIwQYMBaAFJY7U/B5M5evfYPvLivMyreGHnJm
# MB0GA1UdDgQWBBR6tE8SiRbd9H4elaQihBengtTMvDANBgkqhkiG9w0BAQsFAAOC
# AQEAdcsKQac88OLWpMJRM+lJQJkbKTLZx2E6JFtJtVOklOy+Uhu2eHuTSl+rdK3E
# wAPTwNDVuPwVw+dmgDkvdyCTnnjuF0XKQniIWVChyc3BgjRPOqLSlATqeqFDjkJr
# uiDc/SDYEpe6YNecbl+M0LIpZTCZRShifEvFSEHFSgP8vOTeJIvwtcffcJvktP1e
# lI5M7uph92fYTdmVTWDq417jmfbIGWOdpt8qrJj0SfzSmd2QRK43eoQt+OTpMvg/
# 8IUCoautNpdlKycGuS7Elxgp/LFc5NzYmv4jZojSn2M6zSQlFYDnRGoQSBFGy+Q2
# xbr8W1ZJ8kRi7+VNhGitt0LgPDCCBVkwggRBoAMCAQICED141/l2SWCyYX308B7K
# hiowDQYJKoZIhvcNAQELBQAwgcoxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJp
# U2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE6MDgG
# A1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3IgYXV0aG9yaXplZCB1
# c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQdWJsaWMgUHJpbWFy
# eSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEzMTIxMDAwMDAwMFoX
# DTIzMTIwOTIzNTk1OVowfzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVj
# IENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTAw
# LgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0Ew
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXgx4AFq8ssdIIxNdok1Fg
# HnH24ke021hNI2JqtL9aG1H3ow0Yd2i72DarLyFQ2p7z518nTgvCl8gJcJOp2lwN
# TqQNkaC07BTOkXJULs6j20TpUhs/QTzKSuSqwOg5q1PMIdDMz3+b5sLMWGqCFe49
# Ns8cxZcHJI7xe74xLT1u3LWZQp9LYZVfHHDuF33bi+VhiXjHaBuvEXgamK7EVUdT
# 2bMy1qEORkDFl5KK0VOnmVuFNVfT6pNiYSAKxzB3JBFNYoO2untogjHuZcrf+dWN
# sjXcjCtvanJcYISc8gyUXsBWUgBIzNP4pX3eL9cT5DiohNVGuBOGwhud6lo43Zvb
# AgMBAAGjggGDMIIBfzAvBggrBgEFBQcBAQQjMCEwHwYIKwYBBQUHMAGGE2h0dHA6
# Ly9zMi5zeW1jYi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBsBgNVHSAEZTBjMGEG
# C2CGSAGG+EUBBxcDMFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93d3cuc3ltYXV0aC5j
# b20vY3BzMCgGCCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3ltYXV0aC5jb20vcnBh
# MDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9zMS5zeW1jYi5jb20vcGNhMy1nNS5j
# cmwwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIB
# BjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRU3ltYW50ZWNQS0ktMS01NjcwHQYD
# VR0OBBYEFJY7U/B5M5evfYPvLivMyreGHnJmMB8GA1UdIwQYMBaAFH/TZafC3ey7
# 8DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBCwUAA4IBAQAThRoeaak396C9pK9+HWFT
# /p2MXgymdR54FyPd/ewaA1U5+3GVx2Vap44w0kRaYdtwb9ohBcIuc7pJ8dGT/l3J
# zV4D4ImeP3Qe1/c4i6nWz7s1LzNYqJJW0chNO4LmeYQW/CiwsUfzHaI+7ofZpn+k
# VqU/rYQuKd58vKiqoz0EAeq6k6IOUCIpF0yH5DoRX9akJYmbBWsvtMkBTCd7C6wZ
# BSKgYBU/2sn7TUyP+3Jnd/0nlMe6NQ6ISf6N/SivShK9DbOXBd5EDBX6NisD3MFQ
# AfGhEV0U5eK9J0tUviuEXg+mw3QFCu+Xw4kisR93873NQ9TxTKk/tYuEr2Ty0BQh
# MYIEPDCCBDgCAQEwgZMwfzELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVj
# IENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTAw
# LgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2RlIFNpZ25pbmcgQ0EC
# EGNJB2TAYSuYQ3vz3gg7KdEwCQYFKw4DAhoFAKBwMBAGCisGAQQBgjcCAQwxAjAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTaAJN+e4GLwOIl1RsqJII/C6tXcTAN
# BgkqhkiG9w0BAQEFAASCAQBpUD320CEJfKRFhefgF8QCZc3VJNGecchgCzRuJc/i
# cduf7AJV58sw9vbE0UbfCZtNmliRxskLL5oM/UJclfiFc4iK9X43fSbsQx3HJSJi
# Scuw4on92XDauo1Vic6EcuirMpCrc3gn0i7poRtim338X+xCIFGLO8t6C81NS+6Z
# n+bI1Ltj07i8er00WCcv+UFg5RbqiAbLslPROP7sk48GiPhmXL4XNm974Dx69b3v
# KdKgK9bGgNihya8o8uIex5zt7KgJ++/kPLv2TAGSByQZpadYyhUpq/pwu3x/99tL
# 6eY3iK5/ZZjbyh3p8t/j3O/wZsqpqj7zO+NE9iFAVXgQoYICCzCCAgcGCSqGSIb3
# DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFu
# dGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5n
# IFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBd
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIwMDIy
# MTE5MTc0NlowIwYJKoZIhvcNAQkEMRYEFOnTG4u39jrMaAncYhGOzBZriaVuMA0G
# CSqGSIb3DQEBAQUABIIBADaFE4WKJn80SBzx5vyG7OayHotXEUC/3mSt5hw0Kv39
# 8RoXgDDM4VpvGKm+pTt5Zq83P2xZICnl0bDWQRa7usBlnAqR4JKJgvitjzBK1d8Z
# ePpXCS73oHSNqmanNUCVqy0v4hmHc8vSWYLqh0pB3urkN6CTR9jfAeVGFMmhKTQE
# Lla0NdcHiFb/YhDQ5CPiVIcU/oIfn3T6TNH8pPDe42+BvO6vCmHGCYvugOVsGAsy
# GuwfeVR5v/auesAygNcO2NvlBQQfsBzat9LLSogfxfaYkTJ/2gekNH0YelJvi9ZM
# NFmKHleVinjzRJ3zb573jNdDbNcAzsCA4bBnFAU9x88=
# SIG # End signature block
