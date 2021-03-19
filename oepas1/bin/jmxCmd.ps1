$scriptdir=split-path -parent $MyInvocation.MyCommand.Definition
$command = $args[0]
$verbose = ""
$argNum = 1
$knownCommand = ""
if($command -eq "refreshagents") {
    $knownCommand = "1"
    $appname = ""
    $waitForAppName = ""
    if($args.length -lt 3) {
        write-output "Error. Not enough parameters for command refreshagents"
        write-output "Command format: refreshagents -appname <application name> [-v]"
        exit
    }
    while ($argNum -lt $args.length)
    {
        if($waitForAppName -ne "") {
            $appname = $args[$argNum]
            $waitForAppName = ""
            $argNum++
            continue
        }
        $key = $args[$argNum]
        if($key -eq "-v") {
            $verbose = "1"
            $argNum++
            continue
        }
        if($key -eq "-appname") {
            $waitForAppName = "1"
            $argNum++
            continue
        }
        write-output "Error. Unknown parmeter $key"
        write-output "Command format: refreshagents -appname <application name>"
        exit
    }
    if($appname -eq "") {
        write-output "Error. Not provided an application name"
        exit
    }
    $query = '{\"O\":\"PASOE:type=OEManager,name=AgentManager\",\"M\":[\"refreshAgents\",\"'+$appname+'\"]}'
    #write-output "$query"
    $result =& $scriptdir\oejmx.bat -Q $query
    if($verbose -ne "") {
        write-output "$result"
    } else {
        $resultTemplate = '{"refreshAgents":{"agents"'
        $aaa = "$result"
        if($aaa.StartsWith($resultTemplate)) {
            write-output "success"
        } else {
            write-output "failure. Set -v key to display jmx result"
        }
    }
        
}
if($command -eq "refreshWeb") {
    $knownCommand = "1"
    $appname = ""
    $webappname = ""
    $waitForAppName = ""
    $waitForWebAppName = ""
    if($args.length -lt 5) {
        write-output "Error. Not enough parameters for command refreshWeb"
        write-output "Command format: refreshWeb -appname <application name> -webappname <webapp name> [-v]"
        exit
    }
    while ($argNum -lt $args.length)
    {
        if($waitForAppName -ne "") {
            $appname = $args[$argNum]
            $waitForAppName = ""
            $argNum++
            continue
        }
        if($waitForWebAppName -ne "") {
            $webappname = $args[$argNum]
            $waitForWebAppName = ""
            $argNum++
            continue
        }
        $key = $args[$argNum]
        if($key -eq "-v") {
            $verbose = "1"
            $argNum++
            continue
        }
        if($key -eq "-appname") {
            $waitForAppName = "1"
            $argNum++
            continue
        }
        if($key -eq "-webappname") {
            $waitForWebAppName = "1"
            $argNum++
            continue
        }
        write-output "Error. Unknown parmeter: $key"
        write-output "Command format: refreshWeb -appname <application name> -webappname <webapp name> [-v]"
        exit
    }
    if($appname -eq "") {
        write-output "Error. Not provided an application name"
        exit
    }
    if($webappname -eq "") {
        write-output "Error. Not provided an webapp name"
        exit
    }
    $query = '{\"O\":\"PASOE:type=OEManager,name=WebTransportManager\",\"M\":[\"refreshWebHandlers\",\"'+$appname+'\",\"'+$webappname+'\"]}'
    #write-output "$query"
    $result =& $scriptdir\oejmx.bat -Q $query
    if($verbose -ne "") {
        write-output "$result"
    } else {
        $resultTemplate = '{"refreshWebHandlers":{"handlers"'
        $aaa = "$result"
        if($aaa.StartsWith($resultTemplate)) {
            write-output "success"
        } else {
            write-output "failure. Set -v key to display jmx result"
        }
    }
        
}
if($knownCommand -eq "") {
   write-output "Error. Unknown comamnd $command"
   write-output "Implemented commands: "
   write-output "  refreshagents"
   write-output "  refreshWeb"
   
}

# SIG # Begin signature block
# MIIXvAYJKoZIhvcNAQcCoIIXrTCCF6kCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnbSU/rG83gvkL4HiYl+DA1rm
# W0mgghLqMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRengQSX4lb5ItDom5X2oZIr0xV9jAN
# BgkqhkiG9w0BAQEFAASCAQC+ae1k0aWcnhMl7+qY6BrpOcInSdIHWnecoikNmtCd
# WICWCU87G8kHOudtjrvqlMdTMmxIE6rnhmrzPKIms+8+W2m8NIvHA1WR4+zDyGsh
# 9fOMOjGW8OcfWRFYGbGXMvK7dHwlK2GVx1ujIpOJ1bzJMSKYd5g1R5cPdbQDr9k9
# 1u0srjuKR6E8+FOs5AD5bWzJPU9foWW0WFw1mFJCOUD+AOa5VzwlVdQ8ka5Oq2Co
# 118NGXSeX/wn+X41Ac6CraNlGRurGTbKNNJp3JihthFV6W8coWw0+Buxark9JR35
# VWGeP02fpEp0SIasnEq3vFUxG9XN34H5Hfbt0aFdLRWooYICCzCCAgcGCSqGSIb3
# DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFu
# dGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5n
# IFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBd
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIwMDIy
# MTE5MTcyNlowIwYJKoZIhvcNAQkEMRYEFHjqv7i96rKLuROcgwOQDUklnSyvMA0G
# CSqGSIb3DQEBAQUABIIBAEeVqH2IG462sy5H1p5b9zIxd72031gbDFYWZ/+cbzfI
# rveWvASmzrs2C3ORBw6S+laFykyuIVVNxSvqcKYxEBX/9JfJBEQzYkDbbgLpn/M4
# 6oDfRSEr2pdGKLnvcxdnTiHN/MVhHH68vIyHBsF3ZS7NbJBvGUnQljx9DGm7ctPG
# eycXBkzIm3GsOdTMEeOCRvDzYLTqXU4DOsj2UMI1LZi8WsqEhI4af+W5qqtfu/SY
# QTGMEpADTpGKwgwgyYeMAVJ17EJ8+RdwzXtRGwxq1ud3udfHL+b5JKsYqER6iXO+
# EeguGdPPN+9Ahnx+Bh1F8GOFyhHkiV3QiyP1w063yXI=
# SIG # End signature block
