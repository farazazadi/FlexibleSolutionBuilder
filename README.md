# Flexible Solution Builder

This PowerShell script helps you create and wire up your `.Net` solution structure and reuse it later if you have a similar requirement.

## How to use it?

By executing the [`Run.bat`](https://github.com/farazazadi/FlexibleSolutionBuilder/blob/main/Run.bat) file and entering the name of your solution, your solution will be created within the same directory as the name you entered.

By default, the created solution will include 10 projects, and its structure will be as follows:

<img src="https://raw.githubusercontent.com/farazazadi/FlexibleSolutionBuilder/main/Images/Structure.png" />

<table>
<thead>
	<tr>
		<th>Project Name</th>
		<th>Project Type</th>
		<th>References</th>
		<th>Nuget Packages</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td>[SolutionName].Domain</td>
		<td>Class Library</td>
		<td>-</td>
		<td>-</td>
	</tr>
	<tr>
		<td>[SolutionName].Application</td>
		<td>Class Library</td>
		<td>Domain</td>
		<td>AutoMapper, FluentValidation, MediatR</td>
	</tr>
	<tr>
		<td>[SolutionName].Infrastructure</td>
		<td>Class Library</td>
		<td>Application</td>
		<td>-</td>
	</tr>
	<tr>
		<td>[SolutionName].WebApi</td>
		<td>Minimal Web Api</td>
		<td>Application, Infrastructure</td>
		<td>-</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.Common</td>
		<td>Class Library</td>
		<td>-</td>
		<td>-</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.Unit</td>
		<td>xUnit Test Project</td>
		<td>Application</td>
		<td>FluentAssertions, Moq</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.Integration</td>
		<td>xUnit Test Project</td>
		<td>Tests.Common, Infrastructure, WebApi</td>
		<td>FluentAssertions, Moq, Respawn</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.EndToEnd</td>
		<td>xUnit Test Project</td>
		<td>Tests.Common, Infrastructure, WebApi</td>
		<td>FluentAssertions</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.Performance</td>
		<td>xUnit Test Project</td>
		<td>-</td>
		<td>FluentAssertions, NBomber, NBomber.Http</td>
	</tr>
	<tr>
		<td>[SolutionName].Tests.Architecture</td>
		<td>xUnit Test Project</td>
		<td>Tests.Common, Domain, Application, Infrastructure, WebApi</td>
		<td>FluentAssertions, TngTech.ArchUnitNET.xUnit</td>
	</tr>
</tbody>
</table>

## How to change it?

If you want to change the default structure of the solution according to your needs, In that case, you must edit, delete the default projects defined in the [`FlexibleSolutionBuilder.ps1`](https://github.com/farazazadi/FlexibleSolutionBuilder/blob/main/FlexibleSolutionBuilder.ps1) file or define your new project type.

For example, if you want to add a Blazor WebAssembly project to your solution, you should define it as follows:

```powershell
$WebUi = [Project]@{
    Name          = "WebUi"
    Type          = [ProjectType]::BlazorWebAssembly
    References    = $null
    NugetPackages = $null
    ParentFolder  = "Source"
}


```
```powershell
$Projects = ..., $WebUi, ...
```
