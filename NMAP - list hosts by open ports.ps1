# Set the filepath for the input and output files, and create the output file.
$FilePath = "$PSScriptRoot"
$InputFile = 'NMAP_all_hosts.txt'
$OutputFile = "$FilePath\Enumerated NMAP.txt"
New-Item -path $OutputFile -ItemType File -Force

# Import the text in the input file.
$FullText = Get-Content -Path $FilePath\$InputFile -Raw

# Parse the text for blocks matching individual scan reports and input each block
# as a Select-String match object item.
$regex_scanreports = "(Nmap scan report for)[\s\S]*?(Network Distance: \d+ hops?)"
$ScanReports = $FullText | Select-String -Pattern $regex_scanreports -AllMatches

# Interpret the data inside each scan report block.
$Data = $ScanReports.Matches | ForEach-Object {
    # Define RegEx patterns.
    $regex_IP = "(\d{1,3}\.){3}(\d{1,3})"
    $regex_MAC = "([0-9a-f]{2}:){5}[0-9a-f]{2}"
    $regex_serviceblock = "(?<=PORT\s+STATE\s+SERVICE\n)[\s\S]*?(?=\nMAC)"
    # Extract IP, MAC, and service data.
    $HostIP = $($_.Value | Select-String -Pattern $regex_IP).Matches.Value
    $MACaddress = $($_.Value | Select-String -Pattern $regex_MAC).Matches.Value
    $ServiceBlock = $($_.Value | 
        Select-String -Pattern $regex_serviceblock).Matches.Value -split "\n"
    # Extract port, state, and service information separately for each block.
    $ServiceList = $ServiceBlock | ForEach-Object {
        $InputLine = $_ -split '\s+'
        $Port = $InputLine[0]
        $State = $InputLine[1]
        $Service = $InputLine[2]
        # Only write the properties if the service state is 'open'.
        if($state -eq "open") {
            New-Object psobject -Property @{
                Port = $Port
                State = $State
                Service = $Service
                }
            }
        }
    # Write the extracted data (including the custom Services object) as 
    # properties inside a custom PSObject named $Data.
    New-Object psobject -Property @{
        Host = $HostIP
        MAC = $MACaddress
        Services = $ServiceList
        }
    }


# Get all unique named ports, sorted numerically by port number.
$OrderedPortList = $data.Services.Port | 
    Sort-Object {[int]$($_ -split "/")[0]} | Get-Unique

# Define a function that will return a service name for a given port.
function identify-servicename {
    param( $PortName)
    $Result = $( $data.services | where {$_.port -eq $PortName} ).service
    if ($Result.count -eq 1) {
        echo "$Result"
    } elseif ($Result.count -ge 1) {
        echo "$($Result[0])"
        }
    }

# Create an object containing pairs of ports and services.
$AllServices = $OrderedPortList | ForEach-Object {
    #echo "Port: $_"
    $Service = identify-servicename $_
    #echo "Service: $Service"
    New-Object psobject -Property @{
        Port = $_
        Service = $Service
        }
    }

# Return all object records with a given port:
$HostsByService = $AllServices | ForEach-Object {
    $PortName = $_.Port
    $PortNumber = [int]$($_.Port -split "/")[0]
    $Protocol = $($_.Port -split "/")[1]
    $Service = $_.Service
    $Hosts = $($data | Where {$_.Services.Port -eq "$portname"}).Host | 
        Sort-Object
    $Count = $Hosts.count
    
    New-Object psobject -Property @{
        PortName = $PortName
        Port = $PortNumber
        Protocol = $Protocol
        Service = $Service
        Hosts = $Hosts
        Count = $Count
        }
    }

# Write the results to the output file.
$(
    ## Count the number of hosts that have a given port open.
    echo "Number of hosts by service:"
    $HostsByService | sort -Property @{e={$_.Count}; Ascending=$false}, Port | 
        Format-Table -Property Count,Protocol,Port,Service  
    echo ""

    # List all hosts that have a given port open.
    echo "List of hosts by service:"
    $HostsByService | ForEach-Object {
        echo "$($_.Port)`t$($_.Service)"
        echo "------------------------"
        echo $_.Hosts
        echo ""
        }
) | Out-File $OutputFile -Append

# Optional: Automatically open the output file.
notepad $OutputFile