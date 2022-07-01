function Export-ADC {
    [CmdletBinding()]
    param (
        [ValidateScript(
            {
                [System.IO.Path]::GetExtension($_.Name) -eq ".csv"
            }
            )]
        [System.IO.FileInfo]$CSVFile = "$env:temp\Export-ADC.csv",
        [ValidateSet("Personal","Group")]
        [System.String]$MailType = "Personal",
        [ValidateSet("OUI","NON")]
        [System.String]$Elearning = "OUI",
        [System.String]$TimeZone = "Europe/Paris",
        [ValidateSet("FR","EN","ES","PT")]
        [System.String]$Language = "FR"
    )
    
    begin {
        if ([System.IO.File]::Exists($CSVFile)) {
            Write-Verbose ('[{0:O}] file {1} exist => remove' -f (get-date),$CSVFile.Name)
            Remove-Item -Path $CSVFile -Force -Confirm:$false
        } 
        Write-Verbose ('[{0:O}] Create file {1}' -f (get-date),$CSVFile.Name)
        New-Item -Path $CSVFile -ItemType File -Force -Confirm:$false

        $header = "email,first_name,last_name,phone_number,language,timezone,email_type,group_name,service_name,elearning`r`n"
        $csv_data = ""
        $csv_data = $csv_data + $header
    }
    
    process {
        $UserList = (Get-ADUser -Filter {((Company -eq "OPHEA") -or (Company -eq "HABITATION MODERNE")) -and (extensionAttribute10 -like "*" )} -Properties mail,GivenName,SurName,mobile,company,extensionAttribute10 | Select-Object mail,GivenName,SurName,mobile,company,extensionAttribute10)
        foreach ($User in $UserList) {
            Write-Verbose ('[{0:O}] {1} in progress' -f (get-date),$User.mail)
            if ($User.mobile -like "0*") {
                $user.mobile = $user.mobile -replace "^0", "(+33)"
            }
            $User.Company = $User.company.ToUpper()
            $csv_data = $csv_data + "$($User.Mail),$($User.GivenName),$($User.SurName),$($User.mobile),$($Language),$($TimeZone),$($MailType),$($User.Company),$($User.extensionAttribute10),$($Elearning)`r`n"
        }
    }
    
    end {
        $csv_data | Out-File -FilePath $CSVFile
    }
}

Export-ADC