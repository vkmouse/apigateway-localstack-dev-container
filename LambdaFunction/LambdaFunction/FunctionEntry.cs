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