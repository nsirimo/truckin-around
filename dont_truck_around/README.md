# DontTruckAround
![App Screenshot](https://github.com/nsirimo/truckin-around/assets/24559644/f3da9634-9922-4ddc-b2c4-baa1a5134796)

## Introduction

Hey there! I’m Nick. I've been a software engineer for quite a while, and in the last three years, I've really come to love working with Elixir and Phoenix. Functional programming has been a refreshing change from the usual object-oriented approach.

I gave myself two focused hours to build this project. I wanted to give an honest attempt so I timed myself. Two hours goes by so fast! It was a fun challenge, and I’d love to hear any feedback or suggestions you have. Thanks for checking it out!

## Thought Process

### Why LiveView?

I chose LiveView because I wanted to spend time making a dynamic Phoenix LiveView app. It’s been a while since I used it, and this project was a great way to refresh my skills. I enjoy learning and wanted to solidify my understanding with a real project.

### What’s the Project About?

The idea is we Dont Truck Around! My app will take in an address or coordinates, then run a calculation of all the food truck and businesses within the area to determine how much foot traffic and competition there will be for your food truck. After that it will place the top 3 spots you should park your food truck for the optimized sales.

## Challenges and Solutions

1. **Data Discovery**: Some fields were missing or unused, so I had to spend time figuring out what was available. Future improvements might include pulling more metadata from Yelp or Google API.
2. **Data Incorrect**: I discovered tons of unformatted data, missing data, etc so I had to fix all this before I continued.

## Future Ideas

- Write more unit tests to ensure everything runs smoothly.
- Add more documentation.
- Allow user input

## Setup and Startup

Before starting the server, please unzip the office-data-sf.csv.zip file in assets as this is a large data set so I had to zip it.

To get your Phoenix server up and running:

1. Run `mix setup` to install and set up dependencies.
2. Start the Phoenix server with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Then, visit [localhost:4000](http://localhost:4000) in your browser.

## Useful Links

- [Official Phoenix Website](https://www.phoenixframework.org/)
- [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
- [Phoenix Documentation](https://hexdocs.pm/phoenix)
- [Phoenix Forum](https://elixirforum.com/c/phoenix-forum)
- [Phoenix Source Code](https://github.com/phoenixframework/phoenix)

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.
