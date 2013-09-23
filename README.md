external247exam
===============

24/7 exam

Given the following Directions :
Fetch the business XML, parse it, then store it in Objective-C structure
https://dl.dropboxusercontent.com/u/101222705/business.xml

Candidate can use any open source lib, like the Google XML parser to help with parsing the data, if needed:
https://code.google.com/p/gdata-objectivec-client/source/browse/#svn%2Ftrunk%2FSource%2FXMLSupport

Display the parsed information on the page in any creative way
Just have 1 native view to display the info

The design of the page UI is open-ended, doesn't need to be fancy, no need of pretty icons
No other UI navigation is necessary. So the app can start by fetching the XML then displaying the information right away
Miscellaneous:

iOS 6+ (don't worry about older versions)
It's a plus if MapView is used, given the lat-long of the business
Check in code to github.com

Provide any description/explanation/thoughts/etc. in the README file on github.


Notes :

- The project is basically a universal single view application. 

- I used MKMapView for the UI and downloaded the XML string using NSURLConnection class. 

- For the XML parser, I used a NSXMLParser.

- Annotations are just simple pop ups with business names. Later on we can implment another creative view given the data.

- This has handling for loading multiple business locations but with the center to the first one.

