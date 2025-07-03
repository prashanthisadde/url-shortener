package main

import (
	"context"
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

var (
	tableName = os.Getenv("TABLE_NAME")
	svc       = dynamodb.New(session.Must(session.NewSession()))
)

type RequestBody struct {
	URL string `json:"url"`
}

type URLMapping struct {
	Shortcode string `json:"shortcode"`
	URL       string `json:"url"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.HTTPMethod {
	case "POST":
		return shortenURL(request)
	case "GET":
		shortcode := request.PathParameters["shortcode"]
		return redirectURL(shortcode)
	default:
		return events.APIGatewayProxyResponse{
			StatusCode: 405,
			Body:       "Method not allowed",
		}, nil
	}
}

func shortenURL(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var body RequestBody
	err := json.Unmarshal([]byte(request.Body), &body)
	if err != nil || body.URL == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: 400, 
			Body:       "Invalid request",
		}, nil
	}

	shortcode := generateCode(6)
	item := URLMapping{Shortcode: shortcode, URL: body.URL}
	av, _ := dynamodbattribute.MarshalMap(item)

	_, err = svc.PutItem(&dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item:      av,
	})
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 500, 
			Body:       "Error storing URL",
		}, nil
	}

	response := map[string]string{
		"short_url": fmt.Sprintf("https://%s/v1/%s", request.Headers["Host"], shortcode),
	}
	respJSON, _ := json.Marshal(response)

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(respJSON),
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}, nil
}

func redirectURL(shortcode string) (events.APIGatewayProxyResponse, error) {
	result, err := svc.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"shortcode": {
				S: aws.String(shortcode),
			},
		},
	})

	if err != nil || result.Item == nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 404, 
			Body:       "Not found",
		}, nil
	}

	var mapping URLMapping
	_ = dynamodbattribute.UnmarshalMap(result.Item, &mapping)

	return events.APIGatewayProxyResponse{
		StatusCode: 301,
		Headers: map[string]string{
			"Location": mapping.URL,
		},
	}, nil
}

func generateCode(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	rand.Seed(time.Now().UnixNano())
	code := make([]byte, length)
	for i := range code {
		code[i] = charset[rand.Intn(len(charset))]
	}
	return string(code)
}

func main() {
	lambda.Start(handler)
}
