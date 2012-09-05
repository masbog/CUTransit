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

1. Install Xcode 4.3 or newer.
2. Get an API Key from http://developer.cumtd.com/
3. (Optional, but recommended) Go to https://code.google.com/apis/console and request a key for Places API.
4. Rename `config.sample.h` to `config.h`. Configure the file. Then add it to the Xcode project.
5. Run the application.

## Overview

The application consists of four tabs: Stops, Trip Planner, Bookmarks, and Routes. The following are their class names and what they typically contain in their navigation stacks.

1. `StopsController` > `StopInfoController` > `StopController` > `DepartureController`
2. `PlannerController` > `ItineraryController`
3. `BookmarksController` > `StopController`
4. `RoutesController` > `RouteController`

In the first tab, a typical workflow is that the user finds a stop on the map, taps the stop to go to the information page (`StopInfoController`), and then selects "Departures" to see incoming buses (`StopController`). The user can then tap a bus's name to see its current location on a map (`DepartureController`).

## To-dos

1. Combine `StopInfoController` and `StopController` into one page. Currently, the only way to get to the `StopInfoController` page is to find a stop on a map in the first tab and tap the details button. We cannot get to the `StopInfoController` page from the bookmarks tab.
2. Update the routes database. The routes information is extracted manually from CUMTD's [maps & schedules book PDF](http://www.cumtd.com/content/pdfs/MTD_MnS_Book_Complete.pdf). The current data in the app are out of date. It would be much better if we could automate the process.

## License

CU Transit is available under the MIT license.
