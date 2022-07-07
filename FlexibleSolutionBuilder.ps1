param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $false)]
    [System.String]$SolutionName
)


enum ProjectType {
    ClassLibrary
    WebApi
    MinimalApi
    Test
    Razor
    Mvc
    BlazorServer
    BlazorWebAssembly
}

class Project {
    [string]$Name
    [ProjectType]$Type
    [Project[]]$References
    [string[]]$NugetPackages
    [string]$ParentFolder
    [string]$Path
}


function Write-HostWithColor {
    param (
        [string]$Text,
        [System.ConsoleColor]$Color
    )

    Write-Host "***********************************************************" -ForegroundColor Green
    Write-Host $Text -ForegroundColor $Color
    Write-Host "***********************************************************" -ForegroundColor Green
}

function Add-BootStrapperFile {
    param (
        [string]$filePath
    )

    new-item "$filePath\Bootstrapper.cs" -Value '// Dependency Injection and...'
}


$Domain = [Project]@{
    Name          = "Domain"
    Type          = [ProjectType]::ClassLibrary
    References    = $null
    NugetPackages = $null
    ParentFolder  = "Source"
}

$Application = [Project]@{
    Name          = "Application"
    Type          = [ProjectType]::ClassLibrary
    References    = $Domain
    NugetPackages =
    "AutoMapper.Extensions.Microsoft.DependencyInjection",
    "FluentValidation.DependencyInjectionExtensions",
    "MediatR.Extensions.Microsoft.DependencyInjection"

    ParentFolder  = "Source"
}

$Infrastructure = [Project]@{
    Name          = "Infrastructure"
    Type          = [ProjectType]::ClassLibrary
    References    = $Application
    NugetPackages = $null
    ParentFolder  = "Source"
}

$WebApi = [Project]@{
    Name          = "WebApi"
    Type          = [ProjectType]::MinimalApi
    References    = $Application, $Infrastructure
    NugetPackages = $null
    ParentFolder  = "Source"
}

$CommonTest = [Project]@{
    Name          = "Common"
    Type          = [ProjectType]::ClassLibrary
    References    = $null
    NugetPackages = $null
    ParentFolder  = "Tests"
}

$UnitTest = [Project]@{
    Name          = "Unit"
    Type          = [ProjectType]::Test
    References    = $Application
    NugetPackages = "FluentAssertions", "Moq"
    ParentFolder  = "Tests"
}

$IntegrationTest = [Project]@{
    Name          = "Integration"
    Type          = [ProjectType]::Test
    References    = $CommonTest, $Infrastructure, $WebApi
    NugetPackages = "FluentAssertions", "Moq", "Respawn"
    ParentFolder  = "Tests"
}

$EndToEndTest = [Project]@{
    Name          = "EndToEnd"
    Type          = [ProjectType]::Test
    References    = $CommonTest, $Infrastructure, $WebApi
    NugetPackages = "FluentAssertions"
    ParentFolder  = "Tests"
}

$PerformanceTest = [Project]@{
    Name          = "Performance"
    Type          = [ProjectType]::Test
    References    = $null
    NugetPackages = "FluentAssertions", "NBomber", "NBomber.Http"
    ParentFolder  = "Tests"
}

$AchitectureTest = [Project]@{
    Name          = "Architecture"
    Type          = [ProjectType]::Test
    References    = $CommonTest, $Domain, $Application, $Infrastructure, $WebApi
    NugetPackages = "FluentAssertions", "TngTech.ArchUnitNET.xUnit"
    ParentFolder  = "Tests"
}


$Projects = $Domain, $Application, $Infrastructure, $WebApi,
            $CommonTest, $UnitTest, $IntegrationTest, $EndToEndTest, $PerformanceTest, $AchitectureTest


Write-HostWithColor "Creating Solution : $SolutionName"  Blue
dotnet new sln -o $SolutionName

foreach ($Project in $Projects) {

    $path = "$SolutionName\$($Project.ParentFolder)\$SolutionName.$($Project.Name)"

    if ($Project.ParentFolder -eq "Tests") {
        $path = "$SolutionName\$($Project.ParentFolder)\$SolutionName.Tests.$($Project.Name)"
    }

    Write-HostWithColor "Creating Project : $path"  Blue

    switch ($Project.Type) {
        ([ProjectType]::ClassLibrary) {
            dotnet new classlib -o $path

            remove-item "$path/Class1.cs"

            if ($Project.ParentFolder -eq "Source") {
                Add-BootStrapperFile $path
            }

            break
        }
        ([ProjectType]::Test) {
            dotnet new xunit -o $path

            remove-item "$path/UnitTest1.cs"

            break
        }
        ([ProjectType]::WebApi) {
            dotnet new webapi -o $path

            break
        }
        ([ProjectType]::MinimalApi) {
            dotnet new webapi -o $path -minimal

            break
        }

        ([ProjectType]::Razor) {
            dotnet new razor -o $path

            break
        }
        ([ProjectType]::Mvc) {
            dotnet new mvc -o $path

            break
        }
        ([ProjectType]::BlazorServer) {
            dotnet new blazorserver -o $path

            break
        }
        ([ProjectType]::BlazorWebAssembly) {
            dotnet new blazorwasm -o $path

            break
        }

    }


    $Project.Path = $path


    if ($null -ne $Project.NugetPackages) {
        Write-HostWithColor "Add nuget packages to: $path"  Blue

        foreach ($package in $Project.NugetPackages) {
            dotnet add .\$path\ package $package
        }
    }


    if ($null -ne $Project.References) {
        Write-HostWithColor "Add references to: $path"  Blue

        foreach ($Reference in $Project.References) {
            dotnet add $path reference $Reference.Path
        }
    }

}


Write-HostWithColor "Adding projects to solution" Cyan
Set-Location $SolutionName
dotnet sln add (Get-ChildItem -r **\*.csproj)


Write-HostWithColor "Building the Solution" Magenta
dotnet build

Set-Location ..
