### 建立類別庫專案

```bash
dotnet new classLib --framework net6.0 --name LambdaFunction
```

### 安裝必要的套件

```bash
cd LambdaFunction
dotnet add package Amazon.Lambda.Core
dotnet add package Amazon.Lambda.Serialization.SystemTextJson
dotnet add package Amazon.Lambda.APIGatewayEvents
```

### 配置專案檔案
  
- 修改 `.csproj` 檔案，加入 `GenerateRuntimeConfigurationFiles` 屬性，以確保在編譯後的輸出中包含 `*.runtimeconfig.json` 檔案。

  ```xml
  <PropertyGroup>
      ...
      <GenerateRuntimeConfigurationFiles>true</GenerateRuntimeConfigurationFiles>
  </PropertyGroup>
  ```

#### 建立 FunctionEntry 類別

- 此類別將作為 Lambda 進入點。它應該包含處理 Lambda 事件的方法和必要的 Lambda 屬性。

  ```cs
  using Amazon.Lambda.Core;
  using Amazon.Lambda.APIGatewayEvents;

  // Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
  [assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

  namespace LambdaFunction
  {
      public class FunctionEntry 
      { 
          public APIGatewayProxyResponse FunctionHandler(APIGatewayProxyRequest lambdaRequest, ILambdaContext context)
          {
              return new APIGatewayProxyResponse
              {
                  Body = lambdaRequest.Body,
                  StatusCode = 200,
              };
          }  
      }
  }
  ```
