$CSVFile = "C:\Scripts\AD_USERS\utilisateurs_utf8.csv" # Chemin du fichier CSV contenant tous les utilisateurs à modifier
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.Prenom.Substring(0,1) + "." + $Utilisateur.Nom
    Write-Output $UtilisateurLogin
    Write-Output ""

    $UserExists = Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin} -ErrorAction SilentlyContinue

    if ($UserExists) {
        Write-Output "L'identifiant $UtilisateurLogin existe, l'utilisateur va être modifié."

        # Propriétés à modifier pour un utilisateur

        $PropertiesToUpdate = @{
            PhysicalDeliveryOfficeName = "Organisation"
            Department = "Service"
            Company    = "Direction"
            Description = "Pôle"
            Title      = "Poste"
            Mobile = "Portable"
            telephoneNumber = "Fixe"
        }

        foreach ($Property in $PropertiesToUpdate.GetEnumerator()) {
            $CSVValue = $Utilisateur.($Property.Value)
            if (-not [string]::IsNullOrEmpty($CSVValue)) {
                Set-ADUser -Identity $UtilisateurLogin -Replace @{$Property.Key = $CSVValue}
                Write-Host "$($Property.Value) : $CSVValue" -ForegroundColor Green
            } else {
                Write-Host "$($Property.Value) : Pas de modification." -ForegroundColor Yellow
            }
        }

        Write-Output "============================================"

    } else {
        Write-Host "L'identifiant $UtilisateurLogin n'existe pas, aucune modification apportée." -ForegroundColor Red
        Write-Output "============================================"
    }
}
