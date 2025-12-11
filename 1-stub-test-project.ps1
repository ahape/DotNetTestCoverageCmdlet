# 1. Create a root folder and enter it
New-Item -Type Directory -Name "CoverageDemo" -Force
Set-Location "CoverageDemo"

# 2. Create Solution
dotnet new sln -n "CoverageDemo"

# 3. Create the Source Library (The code to be tested)
dotnet new classlib -n "CoverageDemo.Core"
dotnet sln add "CoverageDemo.Core/CoverageDemo.Core.csproj"

# 4. Create the Test Project (xUnit)
dotnet new xunit -n "CoverageDemo.Tests"
dotnet sln add "CoverageDemo.Tests/CoverageDemo.Tests.csproj"

# 5. Link them: Test Project needs reference to Core Project
dotnet add "CoverageDemo.Tests/CoverageDemo.Tests.csproj" reference "CoverageDemo.Core/CoverageDemo.Core.csproj"

# 6. Ensure Coverlet is added (It's usually default in xUnit, but this ensures it)
dotnet add "CoverageDemo.Tests/CoverageDemo.Tests.csproj" package coverlet.collector
