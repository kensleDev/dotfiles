# Feature skeleton

Create a new feature folder:

```
references/TodoApi/Features/<FeatureName>/
  <FeatureName>Endpoints.cs
  <FeatureName>Handlers.cs
  Models/
    <FeatureName>.cs
    <FeatureName>Dto.cs
    <FeatureName>Requests.cs
  Services/
    I<FeatureName>Service.cs
    <FeatureName>Service.cs
  Validation/
    Create<FeatureName>Validator.cs
    Update<FeatureName>Validator.cs
  Mapping/
    <FeatureName>Mapper.cs
```

Register services in `references/TodoApi/Common/Extensions/ServiceCollectionExtensions.cs` and map endpoints in `references/TodoApi/Program.cs`.
