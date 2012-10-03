# CU Transit

CU Transit is an iOS application to get important information about bus service in Champaign-Urbana area.

Main features:

* Find nearby bus stops
* Check bus departure times
* Track bus location
* Find directions
* Offline maps and schedules
* Bookmarks

Website: http://jitouch.com/cutransit

## Getting Started

To run CU Transit on an iOS simulator:

1. Install Xcode 4.5 or newer.
2. Get an API Key from http://developer.cumtd.com/
3. (Optional, but recommended) Go to https://code.google.com/apis/console and request a key for Places API.
4. Rename `config.sample.h` to `config.h`. Then configure the file.
5. Run the application.

## Overview

The application consists of four tabs: Stops, Trip Planner, Bookmarks, and Routes. The following are their class names and what they typically contain in their navigation stacks.

1. `StopsController` > `StopController` > `DepartureController`
2. `PlannerController` > `ItineraryController`
3. `BookmarksController` > `StopController`
4. `RoutesController` > `RouteController`

In the first tab, a typical workflow is that the user finds a bus stop on the map, taps the bus stop to go to the information page (`StopController`), and then selects the "Departures" tab to see incoming buses. The user can then tap a bus's name to see its current location on a map (`DepartureController`).

## To-do

* Update the routes database. The routes information is extracted manually from CUMTD's [maps & schedules book PDF](http://www.cumtd.com/content/pdfs/MTD_MnS_Book_Complete.pdf). The current data in the app are out of date. It would be much better if we could automate the process.

## License

CU Transit is available under the MIT license.
