# Tile Feed

## Summary

This app displays a list of diferent items: images, websites, videos and shopping list. These items are fetched from a server and stored locally.

You can tap on each item to see its detail.

## Requirements

- iOS 15
- Xcode 13

## Motivation

This app is just an excuse to work with some of the most used iOS frameworks in a "real" project, which is way more challenging than following a course.

The second goal of this project is to use an architecture than can scale, even if it's too big for this tiny app. Being forced to build an app from scrach provides a different prespective than working inside a team with an already stablished architecture. 

## Proposal

### Architecture

This app uses Clean Architecture and MVVM. The app structure is the following:

**Data layer**

- <ins>Datasources</ins>: The purpose of a datasource is to simplify the process of obtaining data. For example the *AlamofireDataSource* knows everything about POST and GET http methods, endpoints, response codes... all of this is contained in the datasource.

- <ins>Repository Implementations</ins>: The goal of the repository is to be a bridge between the data and the domain layer. My personal take on this is that the implementation belongs to the data layer (as it works with it) and the interface belongs to the domain layer. Thanks to the repository changes the presentation layer doesn't have to be affected by changes in the data layer. A repository works with multiple datasources to obtain the requested data.

**Domain layer**

- <ins> Repository interfaces </ins>: The visible face of the repository. Knows only about domain.

- <ins> Usecases </ins>: Usecases are responsible for managing data-flow. This app is a perfect example of that. The *GetTilesUseCase* handles all the logic related to using server or local data. Another good example would be an api call that depends on another, that would also be a good usecase example.

- <ins> Entities </ins>: The app data. The repository creates them by mapping the datasource output into what we want to use in our presentation layer. 

**Presentation layer**

- <ins> ViewModel </ins>: The purpose of the viewModels is to make views simpler, as it handles all the needed logic. It also helps with testing as you can test the business logic without depending on the view.

- <ins> View </ins>: The user interface of the app. Sends events to the viewmodel and reflects the current state of the app.

**Infrastructure**

This layer contains everything that is needed in several layers. It is mostly composed by utils.

### Frameworks

- [Alamofire](https://github.com/Alamofire/Alamofire): Used it to make API requests in a simple way.
- CoreData: Used to manage local storage.
- SwiftUI: Used to build views in a modern way that's also easier to integrate in a reactive flow.
- Combine: Used to build the app using ractive programming.

### Testing

This project also features Unit, UI and Integration Testing using the native XCTest framework.
With Unit testing I test each item separately using mocks. With integration testing only the datasource is mocked, this way I can test all the steps from the viewModel to the datasource.

### CI

Every commit and pull request to 'main' branch will trigger a Github Action that builds and tests the project.
