#!/bin/bash

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"
    local api_url="$3"

    while true; do
        # Prepare the JSON payload
        json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
        )

        # Send the request using curl and capture both the response and status code
        response=$(curl -s -w "\n%{http_code}" -X POST "$api_url" \
            -H "Authorization: Bearer $api_key" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$json_data")

        # Extract the HTTP status code from the response
        http_status=$(echo "$response" | tail -n 1)
        body=$(echo "$response" | head -n -1)

        if [[ "$http_status" -eq 200 ]]; then
            # Check if the response is valid JSON
            echo "$body" | jq . > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                # Print the question and response content
                echo "✅ [SUCCESS] API: $api_url | Message: '$message'"

                # Extract the response message from the JSON
                response_message=$(echo "$body" | jq -r '.choices[0].message.content')
                
                # Print both the question and the response
                echo "Question: $message"
                echo "Response: $response_message"
                break  # Exit loop if request was successful
            else
                echo "⚠️ [ERROR] Invalid JSON response! API: $api_url"
                echo "Response Text: $body"
            fi
        else
            echo "⚠️ [ERROR] API: $api_url | Status: $http_status | Retrying in 2s..."
            sleep 2
        fi
    done
}

# Define a list of predefined messages
user_messages=(
    "Who is the president of the United States"
    "What is the capital of Japan"
    "How does photosynthesis work"
    "Why is the sky blue"
    "Who wrote the book 1984"
    "Tell me a joke"
    "Can you create a short bedtime story"
    "What’s the best way to stay motivated"
    "If you could time travel where would you go"
    "What’s your favorite food"
    "If I have 5 apples and give 2 away how many do I have left"
    "What is 23 × 17"
    "Can you explain gravity in simple words"
    "How can I improve my memory"
    "What are some easy exercises to stay fit"
    "What are the best habits for success"
    "Can you describe a futuristic city"
    "Do you think AI will replace human jobs"
    "How do you define happiness"
    "What are the pros and cons of social media"
    "What is Python used for"
    "Can you explain what an API is"
    "How does blockchain technology work"
    "What is the difference between RAM and ROM"
    "What is the largest animal on Earth"
    "How many continents are there"
    "Who invented the lightbulb"
    "What is the boiling point of water"
    "What is the difference between a mammal and a reptile"
    "How does a computer work"
    "What is a black hole"
    "What are the main colors of the rainbow"
    "How do airplanes stay in the sky"
    "What is the fastest land animal"
    "What is the longest river in the world"
    "How old is the Earth"
    "Who discovered electricity"
    "What is the speed of light"
    "What are the phases of the moon"
    "What is the chemical formula for water"
    "Can you name the planets in our solar system"
    "What is the square root of 64"
    "What is the tallest mountain in the world"
    "How does the internet work"
    "What is the capital of France"
    "What does DNA stand for"
    "How many bones are in the human body"
    "How do fish breathe underwater"
    "What causes the seasons to change"
    "What is a food chain"
    "What is the smallest country in the world"
    "What are the primary colors"
    "How does a microwave oven work"
    "What is the hottest planet in the solar system"
    "What does the word “photosynthesis” mean"
    "What is the most common gas in the Earth’s atmosphere"
    "What is the largest desert in the world"
    "How many hours are in a day"
    "How many days are in a year"
    "What is the smallest planet in the solar system"
    "Who was the first man on the moon"
    "Why do we need sleep"
    "What is a solar eclipse"
    "What is the function of the heart"
    "What is the difference between weather and climate"
    "What is an ecosystem"
    "What is a cell"
    "How do magnets work"
    "What is the tallest tree in the world"
    "Who painted the Mona Lisa"
    "How do plants grow"
    "What is the main purpose of the lungs"
    "What is the largest ocean in the world"
    "How do clouds form"
    "What is a virus"
    "Why do we have two eyes"
    "What is the capital of Australia"
)

# Ask the user to input API Key and Domain URL
echo -n "Enter your API Key: "
read api_key
echo -n "Enter the Domain URL: "
read api_url

# Exit if the API Key or URL is empty
if [ -z "$api_key" ] || [ -z "$api_url" ]; then
    echo "Error: Both API Key and Domain URL are required!"
    exit 1
fi

# Ask the user how many threads to use
echo -n "Enter the number of threads you want to use: "
read num_threads

if ! [[ "$num_threads" =~ ^[0-9]+$ ]] || [ "$num_threads" -lt 1 ]; then
    echo "Invalid input. Please enter an integer greater than 0."
    exit 1
fi

# Function to run the thread
start_thread() {
    while true; do
        # Pick a random message from the predefined list
        random_message="${user_messages[$RANDOM % ${#user_messages[@]}]}"
        send_request "$random_message" "$api_key" "$api_url"
    done
}

# Start the threads
for ((i = 0; i < num_threads; i++)); do
    start_thread &
done

# Wait for all threads to finish (this will run indefinitely)
wait

echo "All requests have been processed."  # This will never be reached because of the infinite loop
