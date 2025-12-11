# How to Verify Your Script

Save your refactored script as `Run-TestsWithCoverage.ps1` in the `CoverageDemo/CoverageDemo.Tests` folder.

### 1. Test Filter: Namespace

Run only tests in the Logic namespace. `StringHelperTests` should NOT run.

```ps1
.\Run-TestsWithCoverage.ps1 -TestNamespace "CoverageDemo.Tests.Logic"
```

### 2. Test Filter: Class

```ps1
.\Run-TestsWithCoverage.ps1 -TestClass "CalculatorTests"
```

### 3. Test Filter: Method

Run only the Add test. The Subtract test should be skipped.

```ps1
.\Run-TestsWithCoverage.ps1 -TestClass "CalculatorTests" -TestMethod "Add_ReturnsSum"
```

### 4. Coverage Filter: Namespace

Run all tests, but only show coverage for `CoverageDemo.Core.Utils`. The report should show 0% coverage for `Calculator` (it will be excluded from the report entirely or grayed out depending on settings).

```ps1
.\Run-TestsWithCoverage.ps1 -CoverNamespace "CoverageDemo.Core.Utils"
```

### 5. Coverage Filter: Class

Run all tests, but only show coverage for the Calculator class.

```ps1
.\Run-TestsWithCoverage.ps1 -CoverClass "Calculator"
```
