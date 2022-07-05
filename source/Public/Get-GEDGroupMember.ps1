#region <Get-GroupMember>	
#After building the function and defining the parameters
#Place yourself here and do ## to generate help
Function Get-GEDGroupMember {
    #Start Function Get-GroupMember
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String]$regex = "^(HM|OP)_\d{2}_\d{2}_.*"
    )

    Begin {
        Write-Verbose "[$(get-date -format "yyyy/MM/dd HH:mm:ss") BEGIN] Starting $($myinvocation.mycommand)"
        Write-Verbose "[$(get-date -format "yyyy/MM/dd HH:mm:ss") BEGIN] Creating an empty HashTable"
        $Result = @()

    }

    Process {
        Get-ADGroup -Filter * | Where-Object { $_.Name -match $regex } | Select-Object Name | Sort-Object Name | ForEach-Object {
            $GroupName = $_.Name
            Get-ADGroupMember -Identity $GroupName | Select-Object -ExpandProperty name | ForEach-Object {
                $Data = Get-ADUser -Filter {Name -eq $_} -Properties Name,SamAccountName
                Write-Verbose ('[{0:O}] User : {1}' -f (Get-Date), $Data.Name)
                if($GroupName.Split("-")[-1] -eq "test") {
                    $ENV = "TEST"
                } else {
                    $ENV = "PROD"
                }
                Write-Verbose ('[{0:O}] Group : {1}' -f (Get-Date), $GroupName)
                if (([REGEX]::Match($GroupName,".*(CONTRIBUTEUR|LECTEUR|ADMIN).*")).Success) {
                    $DROIT = [REGEX]::Match($GroupName,".*(CONTRIBUTEUR|LECTEUR|ADMIN).*").Captures.groups[1].value
                } else {
                    $DROIT = "CONTRIBUTEUR"
                }
                $User = [PSCustomObject]@{
                    Acteur  = $Data.name
                    'Groupe IRISNext' = $GroupName
                    'Connexion GED' = $Data.SamAccountName
                    'ENV' = $ENV
                    'DROIT' = $DROIT
                }
                $Result += $User
            }
        }
    }

    End {
        Write-Verbose "[$(get-date -format "yyyy/MM/dd HH:mm:ss") END] Ending $($myinvocation.mycommand)"
        Return $Result
    }
}	 #End Function Get-GroupMember
#endregion <Get-GroupMember>