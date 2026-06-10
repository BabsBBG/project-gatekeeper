<#
.SYNOPSIS
    Creates the 16 Helix and Pulse users for Project Gatekeeper.
.DESCRIPTION
    Uses Microsoft Graph PowerShell to create users, assign them to security groups,
    and set an initial password. Requires the Microsoft.Graph module.
.NOTES
    Run this script in an elevated PowerShell session after connecting to your tenant.
    The initial password is set to "Helix@Gatekeeper2026!" and users must change it at first sign-in.
#>

# Parameters
$initialPassword = "Helix@Gatekeeper2026!"
$tenantDomain = "bbgseclab.onmicrosoft.com"

# Ensure the Microsoft.Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft.Graph module not found. Installing..." -ForegroundColor Yellow
    Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
}

# Connect to Graph (will prompt for login)
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"

# Get all target groups (create a hashtable for quick lookup)
$groups = @{}
Get-MgGroup -Filter "displayName eq 'HLX-IT-Admins' or displayName eq 'HLX-NOC-Engineers' or displayName eq 'HLX-Corporate-Staff' or displayName eq 'HLX-Field-Ops' or displayName eq 'PLS-Legacy-Users'" | ForEach-Object {
    $groups[$_.DisplayName] = $_.Id
}

# Password profile (force change on next login)
$passwordProfile = @{
    Password = $initialPassword
    ForceChangePasswordNextSignIn = $true
}

# User definitions
$users = @(
    # IT Admins
    @{ DisplayName = "Martin Odegaard (HLX)"; UPN = "martin.odegaard@$tenantDomain"; JobTitle = "IT Administrator"; Department = "IT Administration"; Group = "HLX-IT-Admins" }
    @{ DisplayName = "Declan Rice (HLX)"; UPN = "declan.rice@$tenantDomain"; JobTitle = "IT Administrator"; Department = "IT Administration"; Group = "HLX-IT-Admins" }
    @{ DisplayName = "William Saliba (HLX)"; UPN = "william.saliba@$tenantDomain"; JobTitle = "IT Administrator"; Department = "IT Administration"; Group = "HLX-IT-Admins" }

    # NOC Engineers
    @{ DisplayName = "Bukayo Saka (HLX)"; UPN = "bukayo.saka@$tenantDomain"; JobTitle = "NOC Engineer"; Department = "Network Operations"; Group = "HLX-NOC-Engineers" }
    @{ DisplayName = "Gabriel Magalhaes (HLX)"; UPN = "gabriel.magalhaes@$tenantDomain"; JobTitle = "NOC Engineer"; Department = "Network Operations"; Group = "HLX-NOC-Engineers" }
    @{ DisplayName = "David Raya (HLX)"; UPN = "david.raya@$tenantDomain"; JobTitle = "NOC Engineer"; Department = "Network Operations"; Group = "HLX-NOC-Engineers" }

    # Corporate Staff
    @{ DisplayName = "Jurrien Timber (HLX)"; UPN = "jurrien.timber@$tenantDomain"; JobTitle = "Business Analyst"; Department = "Corporate"; Group = "HLX-Corporate-Staff" }
    @{ DisplayName = "Kai Havertz (HLX)"; UPN = "kai.havertz@$tenantDomain"; JobTitle = "Project Manager"; Department = "Corporate"; Group = "HLX-Corporate-Staff" }
    @{ DisplayName = "Leandro Trossard (HLX)"; UPN = "leandro.trossard@$tenantDomain"; JobTitle = "Finance Analyst"; Department = "Corporate"; Group = "HLX-Corporate-Staff" }
    @{ DisplayName = "Viktor Gyokeres (HLX)"; UPN = "viktor.gyokeres@$tenantDomain"; JobTitle = "Operations Manager"; Department = "Corporate"; Group = "HLX-Corporate-Staff" }

    # Field Operations
    @{ DisplayName = "Gabriel Martinelli (HLX)"; UPN = "gabriel.martinelli@$tenantDomain"; JobTitle = "Field Operations Engineer"; Department = "Field Operations"; Group = "HLX-Field-Ops" }
    @{ DisplayName = "Gabriel Jesus (HLX)"; UPN = "gabriel.jesus@$tenantDomain"; JobTitle = "Field Operations Engineer"; Department = "Field Operations"; Group = "HLX-Field-Ops" }

    # Pulse Legacy Users
    @{ DisplayName = "Oleksandr Zinchenko (PLS)"; UPN = "pls-oleksandr.zinchenko@$tenantDomain"; JobTitle = "Network Engineer"; Department = "Pulse Networks [Legacy]"; Group = "PLS-Legacy-Users" }
    @{ DisplayName = "Jakub Kiwior (PLS)"; UPN = "pls-jakub.kiwior@$tenantDomain"; JobTitle = "Network Engineer"; Department = "Pulse Networks [Legacy]"; Group = "PLS-Legacy-Users" }
    @{ DisplayName = "Reiss Nelson (PLS)"; UPN = "pls-reiss.nelson@$tenantDomain"; JobTitle = "Systems Administrator"; Department = "Pulse Networks [Legacy]"; Group = "PLS-Legacy-Users" }
    @{ DisplayName = "Albert Lokonga (PLS)"; UPN = "pls-albert.lokonga@$tenantDomain"; JobTitle = "IT Support"; Department = "Pulse Networks [Legacy]"; Group = "PLS-Legacy-Users" }
)

# Create users and add to groups
foreach ($user in $users) {
    try {
        # Check if user already exists
        $existing = Get-MgUser -Filter "userPrincipalName eq '$($user.UPN)'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "User $($user.UPN) already exists – skipping." -ForegroundColor Yellow
            continue
        }

        # Create user
        $newUser = New-MgUser `
            -DisplayName $user.DisplayName `
            -UserPrincipalName $user.UPN `
            -MailNickname ($user.UPN.Split("@")[0] -replace "\.", "-") `
            -AccountEnabled `
            -PasswordProfile $passwordProfile `
            -JobTitle $user.JobTitle `
            -Department $user.Department `
            -UsageLocation "NG"

        Write-Host "Created: $($user.DisplayName) ($($user.UPN))" -ForegroundColor Green

        # Add to group
        $groupId = $groups[$user.Group]
        if ($groupId) {
            New-MgGroupMember -GroupId $groupId -DirectoryObjectId $newUser.Id
            Write-Host "  -> Added to group: $($user.Group)" -ForegroundColor Cyan
        } else {
            Write-Host "  -> Warning: Group '$($user.Group)' not found – user not added to group." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Failed to create $($user.UPN): $_" -ForegroundColor Red
    }
}

Write-Host "`nAll 16 users processed." -ForegroundColor Yellow
Write-Host "Break‑glass accounts (bg-01, bg-02) and B2B contractors must be created manually." -ForegroundColor Yellow