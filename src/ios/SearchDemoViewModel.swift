import SwiftUI
import Combine
import DGis

final class SearchDemoViewModel: ObservableObject {
    //Get Current Location
    private let locationManagerFactory: () -> LocationService?
    private var locationService: LocationService?
    private var moveCameraCancellable: DGis.Cancellable?
//    let sdk: Container?
    
    let searchStore: SearchStore

    private let searchManagerFactory: () -> SearchManager
    private let map: Map
//    private let context: Container

//    init(sdk: Container, locationManagerFactory: @escaping () -> LocationService?, searchManagerFactory:
    init(locationManagerFactory: @escaping () -> LocationService?, searchManagerFactory: @escaping () -> SearchManager, map: Map) {
//        self.sdk = sdk
        self.locationManagerFactory = locationManagerFactory
        self.searchManagerFactory = searchManagerFactory
        self.map = map
        let service = SearchService(
            searchManagerFactory: self.searchManagerFactory,
            map: self.map,
            scheduler: DispatchQueue.main
        )
        let reducer = SearchReducer(service: service)
        self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
        
//        // Create a data source.
//        let source = MyLocationMapObjectSource(
//            context: sdk.context,
//            directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
//        )
//
//        // Add the data source to the map.
//        self.map.addSource(source: source)
        
    }

    func makeSearchViewModel() -> SearchViewModel {
        let service = SearchService(
            searchManagerFactory: self.searchManagerFactory,
            map: self.map,
            scheduler: DispatchQueue.main
        )
        let viewModel = SearchViewModel(
            searchStore: self.searchStore,
            searchService: service
        )
        return viewModel
    }
    
    func showCurrentPosition() {
//        let source = MyLocationMapObjectSource(
//            context: self.sdk.context,
//            directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
//        )

        // Add the data source to the map.
//        self.map.addSource(source: source)
        
        if self.locationService == nil {
            self.locationService = self.locationManagerFactory()
        }
        self.locationService?.getCurrentPosition { (coordinates) in
            DispatchQueue.main.async {
                self.moveCameraCancellable?.cancel()
                self.moveCameraCancellable = self.map
                    .camera
                    .move(
                        position: CameraPosition(
                            point: GeoPoint(latitude: .init(value: coordinates.latitude), longitude: .init(value: coordinates.longitude)),
                            zoom: .init(value: 16),
                            tilt: .init(value: 15),
                            bearing: .init(value: 0)
                        ),
                        time: 1.0,
                        animationType: .linear
                    ).sink { _ in
                        print("Move to current location")
                    } failure: { error in
                        print("Something went wrong: \(error.localizedDescription)")
                    }
            }
        }
    }
}
