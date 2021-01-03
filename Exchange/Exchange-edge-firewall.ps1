#----------------Settings----------------#
#--Firewall - Transport service--#
$config = get-content "C:\Store\WR\DSC\Exchange\DSC-config.json" | ConvertFrom-Json
#--Firewall - Transport service--#


#----------------Settings----------------#


#----------------Settings - arguments binding----------------#
<#
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName
)
#>
$computers = ($config."network hosts"."edge".nl , $config."network hosts"."edge".fr | % { $_ } | % { Resolve-DnsName $_ }).NameHost
#----------------Settings - arguments binding----------------#




#----------------Configuration----------------#
foreach ($computer in $Computers) {
    Configuration Edge
    { 
        Import-DSCResource -ModuleName NetworkingDsc
        Node $Computer 
        {
            Firewall EdgeTransport {
                Ensure        = 'Present'
                # Name          = '{C9EC360F-6516-4154-920D-E28C211BDF9B}'
                name          = (invoke-command -scriptblock { (Get-NetFirewallRule -DisplayName "MSExchangeEdgeTransportWorker").name } -ComputerName $computer -Credential $creds)
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts"."Microsoft Exchange".nl , $config."network hosts"."Microsoft Exchange".fr , $config."network hosts".lb.fr , $config."network hosts".lb.nl, $config."network hosts".pineapp, $config."network hosts".apps, $config."network hosts".zabbix, $config."network hosts".postfix, $config."network hosts".edge.fr, $config."network hosts".edge.nl, $config."network hosts"."adm-aleksandr.k" | % { $_ }
                Enabled       = "True"
            }

            Firewall Zabbix {
                Ensure        = 'Present'
                Name          = "[Zabbix] Agent"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = ($config."network hosts"."zabbix" | % { $_ })
                Enabled       = "True"
            }
            Firewall RDP-tcp {
                Ensure        = 'Present'
                Name          = "RemoteDesktop-UserMode-In-UDP"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = ($config."network hosts"."adm-aleksandr.k", $config."network hosts".apps | % { $_ })
                Enabled       = "True"
            }
            Firewall RDP-udp {
                Ensure        = 'Present'
                Name          = "RemoteDesktop-UserMode-In-TCP"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = ($config."network hosts"."adm-aleksandr.k", $config."network hosts".apps | % { $_ })
                Enabled       = "True"
            }
            Firewall ICMP {
                Ensure    = 'Present'
                Name      = "FPS-ICMP4-ERQ-In"
                Direction = 'InBound'
                Enabled   = "True"
            }
            Firewall RemoteMMC {
                Ensure    = 'Present'
                Name      = "RemoteEventLogSvc-NP-In-TCP"
                Direction = 'InBound'
                Enabled   = "True"
            }
            Firewall RemoteMMC2 {
                Ensure    = 'Present'
                Name      = "RemoteEventLogSvc-In-TCP"
                Direction = 'InBound'
                Enabled   = "True"
            }
        }
    }
    #----------------Create MOF file----------------#
    Edge -output C:\store\wr\DSC\Exchange
    #----------------Create MOF file----------------#

}
#----------------Configuration----------------#





