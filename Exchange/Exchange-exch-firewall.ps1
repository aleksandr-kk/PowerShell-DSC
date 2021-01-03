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
$computers = ($config."network hosts".'Microsoft Exchange'.FR , $config."network hosts".'Microsoft Exchange'.NL | % { $_ } | %{Resolve-DnsName $_}).NameHost
#----------------Settings - arguments binding----------------#



#----------------Configuration----------------#
foreach ($computer in $Computers) {
    Configuration Exchange
    { 
        Import-DSCResource -ModuleName NetworkingDsc
        Node $Computer
        {
            Firewall Transport1 {
                Ensure        = 'Present'
                # Name          = '{C9EC360F-6516-4154-920D-E28C211BDF9B}'
                name          = (invoke-command -scriptblock { (Get-NetFirewallRule -DisplayName "MSExchangeTransportWorker (GFW) (TCP-In)").name } -ComputerName $computer -Credential $creds)
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts".Zabbix, $config."network hosts".APPs, $config."network hosts"."edge".nl, $config."network hosts"."edge".fr, $config."network hosts"."Microsoft Exchange".nl, $config."network hosts"."Microsoft Exchange".fr | % { $_ }
                Enabled       = "True"
            }

            Firewall Transport2 {
                Ensure        = 'Present'
                # Name          = '{C9EC360F-6516-4154-920D-E28C211BDF9B}'
                name          = (invoke-command -scriptblock { (Get-NetFirewallRule -DisplayName "MSExchangeFrontendTransport (TCP-In)").name } -ComputerName $computer -Credential $creds)
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts".Zabbix, $config."network hosts".APPs, $config."network hosts"."edge".nl, $config."network hosts"."edge".fr, $config."network hosts"."Microsoft Exchange".nl, $config."network hosts"."Microsoft Exchange".fr | % { $_ }
                Enabled       = "True"
            }
            Firewall Transport3 {
                Ensure        = 'Present'
                # Name          = '{C9EC360F-6516-4154-920D-E28C211BDF9B}'
                name          = (invoke-command -scriptblock { (Get-NetFirewallRule -DisplayName "MSExchangeTransportWorker (TCP-In)").name } -ComputerName $computer -Credential $creds)
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts".Zabbix, $config."network hosts".APPs, $config."network hosts"."edge".nl, $config."network hosts"."edge".fr, $config."network hosts"."Microsoft Exchange".nl, $config."network hosts"."Microsoft Exchange".fr | % { $_ }
                Enabled       = "True"
            }

            Firewall Pop3 {
                Ensure        = 'Present'
                # Name          = '{C9EC360F-6516-4154-920D-E28C211BDF9B}'
                name          = (invoke-command -scriptblock { (Get-NetFirewallRule -DisplayName "MSExchangePOP3 (TCP-In)").name } -ComputerName $computer -Credential $creds)
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts".Zabbix, $config."network hosts".APPs, $config."network hosts"."edge".nl, $config."network hosts"."edge".fr, $config."network hosts"."Microsoft Exchange".nl, $config."network hosts"."Microsoft Exchange".fr, $config."network hosts".LB.fr, $config."network hosts".lb.nl | % { $_ }
                Enabled       = "True"
            }


            Firewall Zabbix {
                Ensure        = 'Present'
                Name          = "[Zabbix] Agent"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts".Zabbix | % { $_ }
                Enabled       = "True"
            }
            Firewall RDP-tcp {
                Ensure        = 'Present'
                Name          = "RemoteDesktop-UserMode-In-UDP"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts"."adm-aleksandr.k", $config."network hosts".APPs | % { $_ }
                Enabled       = "True"
            }
            Firewall RDP-udp {
                Ensure        = 'Present'
                Name          = "RemoteDesktop-UserMode-In-TCP"
                Direction     = 'InBound'
                #RemoteAddress = ('any')
                RemoteAddress = $config."network hosts"."adm-aleksandr.k", $config."network hosts".APPs | % { $_ }
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
    #----------------Configuration----------------#


    #----------------Create MOF file----------------#
    Exchange -output C:\store\wr\DSC\Exchange
    #----------------Create MOF file----------------#

}





