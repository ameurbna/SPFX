param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath common.psm1) -Force

try {

    # Indicates if the current project is a VB project
    $IsVbProject = ($project.CodeModel.Language -eq [EnvDTE.CodeModelLanguageConstants]::vsCMLanguageVB)

    # Indicates if the current project is an MVC project
    $IsMvcProject = ($project.Object.References | Where-Object { $_.Identity -eq "System.Web.Mvc" }) -ne $null

    # The filters folder.
    $FiltersProjectItem = $project.ProjectItems.Item("Filters");

    if ($IsVbProject) {
        # For VB project, delete TokenHelper.cs, SharePointContext.cs and SharePointContextFilterAttribute.cs
        $project.ProjectItems | Where-Object { ($_.Name -eq "TokenHelper.cs") -or ($_.Name -eq "SharePointContext.cs") } | ForEach-Object { $_.Delete() }
        $FiltersProjectItem.ProjectItems | Where-Object { ($_.Name -eq "SharePointContextFilterAttribute.cs") } | ForEach-Object { $_.Delete() }

        # Delete SharePointContextFilterAttribute.vb if the web project is not MVC.
        if (!$IsMvcProject) {
            $FiltersProjectItem.ProjectItems | Where-Object { $_.Name -eq "SharePointContextFilterAttribute.vb" } | ForEach-Object { $_.Delete() }
        }

        # Add Imports for VB project
        $VbImports | ForEach-Object {
            if (!($project.Object.Imports -contains $_)) {
                $project.Object.Imports.Add($_)
            }
        }
    }
    else {
        # For CSharp project, delete TokenHelper.vb, SharePointContext.vb and SharePointContextFilterAttribute.vb
        $project.ProjectItems | Where-Object { ($_.Name -eq "TokenHelper.vb") -or ($_.Name -eq "SharePointContext.vb") } | ForEach-Object { $_.Delete() }
        $FiltersProjectItem.ProjectItems | Where-Object { ($_.Name -eq "SharePointContextFilterAttribute.vb") } | ForEach-Object { $_.Delete() }

        # Delete SharePointContextFilterAttribute.cs if the web project is not MVC.
        if (!$IsMvcProject) {
            $FiltersProjectItem.ProjectItems | Where-Object { $_.Name -eq "SharePointContextFilterAttribute.cs" } | ForEach-Object { $_.Delete() }
        }
    }
    
    # Delete the Filters folder if there is no item in it.
    if ($FiltersProjectItem.ProjectItems.Count -eq 0) {
        try {
            $FiltersProjectItem.Delete()
        }
        catch {
            Write-Host "Error while deleting the Filters folder: " + $_.Exception -ForegroundColor Yellow
        }
    }

    # Set CopyLocal = True as needed
    Foreach ($spRef in $CopyLocalReferences) {
        $project.Object.References | Where-Object { $_.Identity -eq $spRef } | ForEach-Object { $_.CopyLocal = $True }
    }

} catch {

    Write-Host "Error while installing package: " + $_.Exception -ForegroundColor Red
    exit
}
# SIG # Begin signature block
# MIIhdwYJKoZIhvcNAQcCoIIhaDCCIWQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBQfEY+NGRkMyCV
# ClOJCX1xVSqPM9I7jehM9+Wmk6pRw6CCC3IwggT6MIID4qADAgECAhMzAAACznya
# zn2QXtK3AAAAAALOMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMTkwNTAyMjEyNTQyWhcNMjAwNTAyMjEyNTQyWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCjCFujRq0kQv+CIenBLay0fR5jqHa+CGpiQvBr0tPkbmSrlC8p6lNhE9Xm0fR/
# nFNFMVO5mika5tL6YO9SSbkIXcLTDiG5wrcyvxp3uXbJ4SZntOKSCujqvNQClo1f
# ekSYqa3Zw9oAnleczgOALpDlVXqBfcL8076HuyznXEpFvrrYeOnLizWnXB6imf6D
# JZWlDAY2AbBMBxKC4s3tekVSXV6xUAIbO9LgwhvyqyXX5pda+A1QybNIDCUgcNGe
# Z3od6NLkcQybhh7ZtiZEpvoFzsjiGyLekibfTgsri9IB0sfYcSVLtViah9O6JTYx
# lQ1ZrP7XiS/lHjJGf6iNI1BRAgMBAAGjggF5MIIBdTAfBgNVHSUEGDAWBgorBgEE
# AYI3PQYBBggrBgEFBQcDAzAdBgNVHQ4EFgQUcz8M7szQ1eRKZIUkjATmgq2AyA8w
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzA4NjUrNDU0MjQzMB8GA1UdIwQYMBaAFOb8
# X3u7IgBY5HJOtfQhdCMy5u+sMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwu
# bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8yMDEw
# LTA3LTA2LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzIwMTAtMDct
# MDYuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggEBABw+6i+NrXj8
# hRtQ8rVGMaV+qjBsLjkqmmciAvHO18z6BsbyfPrZSExHwyOs8zaDKX53DGpKbmSY
# CpDTN5T+VMDPfAfp29pryBbBHmAJFgK7TP+zWxHumNeVCkQgt/pA/e09OD4ISFhs
# hjFQf4evxJCKxrFlYIL+tPLB0FqcwcgxDsstlthoSOaReaNLMirjAaNpFG+gnVxB
# Rct7QEeBrJw4KCRO0kw43k5SpkHcLiupyOVCanz9MfAd5IbBmBU9hAkI1mKPdXbg
# XWcQoPCJrNeV5WQnqyYGlrjAFhs8UZH9XNNbj2iCvnVMfd7ggQ1troOxkiGeuTZg
# /uz/G+xsp0YwggZwMIIEWKADAgECAgphDFJMAAAAAAADMA0GCSqGSIb3DQEBCwUA
# MIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQD
# EylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0x
# MDA3MDYyMDQwMTdaFw0yNTA3MDYyMDUwMTdaMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDpDmRQ
# eWe1xOP9CQBMnpSs91Zo6kTYz8VYT6mldnxtRbrTOZK0pB75+WWC5BfSj/1EnAjo
# ZZPOLFWEv30I4y4rqEErGLeiS25JTGsVB97R0sKJHnGUzbV/S7SvCNjMiNZrF5Q6
# k84mP+zm/jSYV9UdXUn2siou1YW7WT/4kLQrg3TKK7M7RuPwRknBF2ZUyRy9HcRV
# Yldy+Ge5JSA03l2mpZVeqyiAzdWynuUDtWPTshTIwciKJgpZfwfs/w7tgBI1TBKm
# vlJb9aba4IsLSHfWhUfVELnG6Krui2otBVxgxrQqW5wjHF9F4xoUHm83yxkzgGqJ
# TaNqZmN4k9Uwz5UfAgMBAAGjggHjMIIB3zAQBgkrBgEEAYI3FQEEAwIBADAdBgNV
# HQ4EFgQU5vxfe7siAFjkck619CF0IzLm76wwGQYJKwYBBAGCNxQCBAweCgBTAHUA
# YgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU
# 1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2Ny
# bC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIw
# MTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0w
# Ni0yMy5jcnQwgZ0GA1UdIASBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUF
# BwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1
# bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5
# AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAadO9X
# Tyl7xBaFeLhQ0yL8CZ2sgpf4NP8qLJeVEuXkv8+/k8jjNKnbgbjcHgC+0jVvr+V/
# eZV35QLU8evYzU4eG2GiwlojGvCMqGJRRWcI4z88HpP4MIUXyDlAptcOsyEp5aWh
# aYwik8x0mOehR0PyU6zADzBpf/7SJSBtb2HT3wfV2XIALGmGdj1R26Y5SMk3YW0H
# 3VMZy6fWYcK/4oOrD+Brm5XWfShRsIlKUaSabMi3H0oaDmmp19zBftFJcKq2rbty
# R2MX+qbWoqaG7KgQRJtjtrJpiQbHRoZ6GD/oxR0h1Xv5AiMtxUHLvx1MyBbvsZx/
# /CJLSYpuFeOmf3Zb0VN5kYWd1dLbPXM18zyuVLJSR2rAqhOV0o4R2plnXjKM+zeF
# 0dx1hZyHxlpXhcK/3Q2PjJst67TuzyfTtV5p+qQWBAGnJGdzz01Ptt4FVpd69+lS
# TfR3BU+FxtgL8Y7tQgnRDXbjI1Z4IiY2vsqxjG6qHeSF2kczYo+kyZEzX3EeQK+Y
# Zcki6EIhJYocLWDZN4lBiSoWD9dhPJRoYFLv1keZoIBA7hWBdz6c4FMYGlAdOJWb
# HmYzEyc5F3iHNs5Ow1+y9T1HU7bg5dsLYT0q15IszjdaPkBCMaQfEAjCVpy/JF1R
# Ap1qedIX09rBlI4HeyVxRKsGaubUxt8jmpZ1xTGCFVswghVXAgEBMIGVMH4xCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jv
# c29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTACEzMAAALOfJrOfZBe0rcAAAAAAs4w
# DQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA3CMSrW
# ZFMuOIH2UaE5kHIJnsIqkEQ8ofONu8U6IMmRMEIGCisGAQQBgjcCAQwxNDAyoBSA
# EgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20w
# DQYJKoZIhvcNAQEBBQAEggEAgwSplLtdKc/VkmKg8Tw8Od9oF9Vt6IAbrwcbMgoW
# 0rkGq3+MseHy+Yy+pJoI1y+NT9N4N/p36WhSqW5aBxeUWuIhNiUuCHVorHISBeKX
# xDYgSiPivWNQAcRO+xGz7RwzwKRC3l0INVtRiIz6mSJXShzo9r7YtIkOdx0icAlw
# OBFHQz2e+TaKwU+JxjcOZ+fPsp6p9cZRT//bQaqEYhZrIHD2Se6HNip+U438l4R0
# UGOy9bcKUhZpEQYPg/CYnPcTCwoL0kv6lBacNr8ey58F2OkokABonzfM5gwUXPoK
# KDdQgNRiGxJUIHbg58rSgTIvBrkFH4vfQdT2JIGJW0+RBKGCEuUwghLhBgorBgEE
# AYI3AwMBMYIS0TCCEs0GCSqGSIb3DQEHAqCCEr4wghK6AgEDMQ8wDQYJYIZIAWUD
# BAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoD
# ATAxMA0GCWCGSAFlAwQCAQUABCDs/rGfN0z/G8/d42pzLmRAqOmWAQKw4lAj7UWl
# Dw38AAIGXURkD27QGBMyMDE5MDgxODA0NDAxNy41MzNaMASAAgH0oIHQpIHNMIHK
# MQswCQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0
# IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNT
# IEVTTjpGQzQxLTRCRDQtRDIyMDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh
# bXAgc2VydmljZaCCDjwwggTxMIID2aADAgECAhMzAAAA4ZyoI889ISGHAAAAAADh
# MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4X
# DTE4MDgyMzIwMjcwMloXDTE5MTEyMzIwMjcwMlowgcoxCzAJBgNVBAYTAlVTMQsw
# CQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRp
# b25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkZDNDEtNEJENC1E
# MjIwMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNlMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm+GsfQtazw9rvY0NadJqRWQ1BcZ2
# Whvkf6eYwl/H+FooHt0S1nr117DTVnlxcELKoY7ZevibZSKL/gwZsFwYOvPB0Eow
# ZAnigKP83h/7TMz5ErsGxJhJ30q+/WMIz1qqO9N0ndrqehpib7lC5+9cwxNl+aFs
# prvYycauzy+1F04owFO1hxJKxzAedkwzGa5iXTgku4eNOUgGDGgyeORlzR2gEEM1
# smKlwbXW4JnKISYd6CiQSfyvH7stEgzTc1oDhcgkEK71LSj0Qq5zEf8pXt2dqvVa
# Skbkyyo7JMWiQhpzgcftsghBCB9w+ysmrGjqb1Sei/pGlC8skm3QmG/3HQIDAQAB
# o4IBGzCCARcwHQYDVR0OBBYEFP8CW61otsqOb4UCz8XkXA1eyLg8MB8GA1UdIwQY
# MBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6
# Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1RpbVN0YVBD
# QV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0
# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljVGltU3RhUENBXzIw
# MTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# DQYJKoZIhvcNAQELBQADggEBABtxCU7b72IrWypLLEVhJG4nGoeMwNFMqL5mdWM0
# 0YxR9jCXJomfqe1Y/PuspesV9Sdu1UvEU4qEkHK4C3jWzkZ1Umyw3CF1UuonR5t4
# gGm9IB40h1ZOIc+4CSKIphYz6alIWp46DN3uGT864jbpqVSMESQ4kLHYAR7U/fUz
# AHafhzU2Qkk9pn2Ht9hXCZ5zVhqypc3jH/7zLxzCL+DkME3K81OgvrJSplLR7ey+
# qtbaAo5A0A35CkMzRN/9fGvjMpMFFErQOFUAbmpaA2Hfm+AmelQCPbYBnz758tNS
# JW0tB5sQmzLN6WIOcfF8XW89uZhiBPlK8rQdchsh4G/p/scwggZxMIIEWaADAgEC
# AgphCYEqAAAAAAACMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0
# aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEyMTM2NTVaFw0yNTA3MDEy
# MTQ2NTVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
# BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwTl/X6f2mUa3RUENWlCgCC
# hfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycEMR9BGxqVHc4JE458YTBZsTBED/FgiIRU
# QwzXTbg4CLNC3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhgRvJYR4YyhB50YWeRX4FU
# sc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScdJGcSchohiq9LZIlQYrFd/XcfPfBX
# day9ikJNQFHRD5wGPmd/9WbAA5ZEfu/QS/1u5ZrKsajyeioKMfDaTgaRtogINeh4
# HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1eFpwBBU8iTQIDAQABo4IB5jCC
# AeIwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2ha
# hW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYG
# A1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3Js
# L3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcB
# AQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kv
# Y2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MIGgBgNVHSABAf8EgZUw
# gZIwgY8GCSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0
# HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBtAGUAbgB0
# AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3ixuCYP4FxAz2do6Ehb7Prpsz1
# Mb7PBeKp/vpXbRkws8LFZslq3/Xn8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRg
# Eop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3fVo/HPKZeUqRUgCvOA8X
# 9S95gWXZqbVr5MfO9sp6AG9LMEQkIjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbl
# jjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFjnXshbcOco6I8+n99lmqQ
# eKZt0uGc+R38ONiU9MalCpaGpL2eGq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ou
# OVd2onGqBooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7cQnfXXSYIghh2rBQHm+9
# 8eEA3+cxB6STOvdlR3jo+KhIq/fecn5ha293qYHLpwmsObvsxsvYgrRyzR30uIUB
# HoD7G4kqVDmyW9rIDVWZeodzOwjmmC3qjeAzLhIp9cAvVCch98isTtoouLGp25ay
# p0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZii8bxyGvWbWu3EQ8l1Bx16HSxVXj
# ad5XwdHeMMD9zOZN+w2/XU/pnR4ZOC+8z1gFLu8NoFA12u8JJxzVs341Hgi62jbb
# 01+P3nSISRKhggLOMIICNwIBATCB+KGB0KSBzTCByjELMAkGA1UEBhMCVVMxCzAJ
# BgNVBAgTAldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
# bnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RkM0MS00QkQ0LUQy
# MjAxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2WiIwoBATAH
# BgUrDgMCGgMVAEHfeI/ZZYJAO2RkotReh2RBwJxNoIGDMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDhA1GYMCIYDzIw
# MTkwODE4MTIyNDU2WhgPMjAxOTA4MTkxMjI0NTZaMHcwPQYKKwYBBAGEWQoEATEv
# MC0wCgIFAOEDUZgCAQAwCgIBAAICJlMCAf8wBwIBAAICEbswCgIFAOEEoxgCAQAw
# NgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgC
# AQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQBvK4P6fpBaMRQLD6mUpz7vpjPY5Mgo
# GhRNJ8te7AODArvXhxBr/W/d5iIk6wy9VQVdPIdYBPs1PbghUHJTlkjWB7WjdKC2
# a35OGgnJu+Tk2IvA2p01EZCZIcppskYcbXSCjHpy8gMLWOdnhEvW0SHHqDOS+HHR
# IwNjiorxpoGnNzGCAw0wggMJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAA4ZyoI889ISGHAAAAAADhMA0GCWCGSAFlAwQCAQUAoIIBSjAa
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIAsscWdQ
# akxKTy/q0dhm+BpsdDb9eeMnb45pJhrGxSFvMIH6BgsqhkiG9w0BCRACLzGB6jCB
# 5zCB5DCBvQQgvGjva3G6ZQnCj+NLoo9Sf35cPFBdzgFpL6kzPDOvbN4wgZgwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAOGcqCPPPSEhhwAA
# AAAA4TAiBCCkX1/IjTMMku+nRtuBRo8S/cosm/5ZLYL/A5lUHWIUrTANBgkqhkiG
# 9w0BAQsFAASCAQBWjKbMjZupEUQy6juXmIzVQwt2IX0tvWZIa7K8uOAa+5WP91Nq
# 2ZsfWzvv5PRNtP608ESqdcPHtkzq7/uA8YwnAyC6bvr+zl3r0CGdZS6h9Le+VtHU
# Bww4OkY68+u8wHzfseQqtXZutr3bwZ6T8qDXW/2xa1VjZfp0C4RYZygw/YCi3EGD
# vsFyD5AmvQWwXmB/sjZWky+elUUf2R00bUesd+041reImTT5CQp4IZEL6Y5LoxwW
# 6DFlLtCPeqGzd72/xoeLuVFlm+feD2IicPRAQjeRIvGhGGDlLoutbQb9dnYmfFQ7
# jJQC1M+GPevcs+NIroKYZDknrCjANwOI1T8/
# SIG # End signature block