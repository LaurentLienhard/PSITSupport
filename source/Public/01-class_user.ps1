enum FormatType {
    UPPERCASE
    LOWERCASE
    FIRSTUPPERCASE
}

class USER {
    [System.String]$FirstName
    [System.String]$LastName
    [System.String]$SamAccountName
    [System.String]$Password

    USER() {
    }

    USER ([System.String]$FirstName, [System.String]$LastName) {
        $This.FirstName = $this.FormatString($FirstName, 'FIRSTUPPERCASE')
        $this.LastName = $this.FormatString($LastName, 'UPPERCASE')
        $this.SamAccountName = $this.FirstName + '.' + $this.LastName
    }

    [System.String] FormatString ([System.String]$Value, [FormatType]$Format) {
        switch ($Format) {
            'UPPERCASE' {
                $Value = ($This.RemoveStringLatinCharacter($Value).ToUpper())
            }
            'LOWERCASE' {
                $Value = ($This.RemoveStringLatinCharacter($Value).ToLower())
            }
            'FIRSTUPPERCASE' {
                $value = (Get-Culture).TextInfo.ToTitleCase(($This.RemoveStringLatinCharacter($Value)))
            }
        }
        $Value = $Value.Trim()
        $Value = $Value -replace ' ', '-'
        return $Value
    }

    [System.String] RemoveStringLatinCharacter ([string]$String) {
        return ([Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding('Cyrillic').GetBytes($String)))
    }

    [void] GeneratePassword ([Int]$NumberOfAlphabets, [Int]$NumberOfNumbers, [Int]$NumberOfSpecialCharacters) {
        if ($NumberOfAlphabets -eq 0) {
            Write-Warning 'The password cannot contain 0 alphabetic characters. The value is changed to 16 by default'
            $NumberOfAlphabets = 16
        }

        if ($NumberOfNumbers -eq 0) {
            Write-Warning 'The password cannot contain 0 numeric characters. The value is changed to 1 by default'
            $NumberOfNumbers = 1
        }

        if ($NumberOfSpecialCharacters -eq 0) {
            Write-Warning 'The password cannot contain 0 special characters. The value is changed to 1 by default'
            $NumberOfSpecialCharacters = 1
        }

        $Alphabets = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z'
        $numbers = 0..9
        $specialCharacters = '!,@,#,$,%,&,(,),>,<,?,\,/,_'
        $array = @()
        $array += $Alphabets.Split(',') | Get-Random -Count $NumberOfAlphabets
        $array[0] = $array[0].ToUpper()
        $array[ - 1] = $array[ - 1].ToUpper()
        $array += $numbers | Get-Random -Count $NumberOfNumbers
        $array += $specialCharacters.Split(',') | Get-Random -Count $NumberOfSpecialCharacters
        $this.Password = (($array | Get-Random -Count $array.Count) -join '')
    }
}