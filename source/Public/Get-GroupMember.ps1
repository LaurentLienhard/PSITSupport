function Get-GroupMember {
    [CmdletBinding(DefaultParameterSetName="ByRegex")]
    param (
        # Parameter help description
        [Parameter(ParameterSetName="ByRegex")]
        [System.String]$regex = "^(HM|OP)_\d{2}_\d{2}_.*",
        [Parameter(ParameterSetName="ByOUPath")]
        [System.String]$OUPath
    )
    
    begin {
        $Result = @()
    }
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "ByRegex" { 
                Write-Verbose ('[{0:O}] ByRegex' -f (Get-Date))
                $GroupList  = Get-ADGroup -Filter * | Where-Object { $_.Name -match $regex } | Select-Object -ExpandProperty Name | Sort-Object Name
             }
            "ByOUPath" { 
                Write-Verbose ('[{0:O}] ByOUPath' -f (Get-Date))
                $GroupList = Get-ADGroup -Filter * -SearchBase $OUPath | Select-Object -ExpandProperty Name | Sort-Object Name
             }
        }

        foreach ($Group in $GroupList) {
            Write-Verbose ('[{0:O}] Find user in {1}' -f (Get-Date),$Group)
            Get-ADGroupMember -Identity $Group | Select-Object -ExpandProperty Name | ForEach-Object {
                Write-Verbose ('[{0:O}] {1}' -f (Get-Date),$_)
                $User = [PSCustomObject]@{
                    'Groupe' = $Group
                    'Utilisateur' = $_
                }
                $Result += $User

            }
    }
}
    
    end {
        return $Result
    }
} 
