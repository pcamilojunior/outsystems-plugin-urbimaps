//
//  Container.swift
//  UrbiMaps
//
//  Created by Andre Grillo on 10/04/2023.
//

import SwiftUI
import DGis

final class Container {
    private(set) var sdk: DGis.Container?
//    private(set) lazy var sdk: DGis.Container = {
//        var cacheOptions: HTTPOptions.CacheOptions?
//        if self.settingsService.httpCacheEnabled {
//            cacheOptions = HTTPOptions.default.cacheOptions
//        } else {
//            cacheOptions = nil
//        }
//
//        let logOptions = LogOptions(
//            osLogLevel: self.settingsService.logLevel,
//            customLogLevel: self.settingsService.logLevel,
//            customSink: nil
//        )
//        let httpOptions = HTTPOptions(timeout: 15, cacheOptions: cacheOptions)
//        let audioOptions = AudioOptions(
//            muteOtherSounds: self.settingsService.muteOtherSounds,
//            audioVolume: AudioVolume(self.settingsService.navigatorVoiceVolumeSource)
//        )
//
//        if let apiKeyPath = Bundle.main.path(forResource: "dgissdk", ofType: "key") {
//            print("⭐️ apiKeyPath: \(apiKeyPath)")
//            let apiKeyOptions = ApiKeyOptions(apiKeyFile: File(path: apiKeyPath))
//            return DGis.Container(
//                apiKeyOptions: apiKeyOptions,
//                logOptions: logOptions,
//                httpOptions: httpOptions,
//                audioOptions: audioOptions
//            )
//        } else {
//            //DEVOLVER CALLBACK DE ERRO!
//            print("🚨 SDK License File not found")
//        }
//
//        return DGis.Container(
//            apiKeyOptions: .default,
//            logOptions: logOptions,
//            httpOptions: httpOptions,
//            audioOptions: audioOptions
//        )
//    }()
    
    init() {
        initializeSDKIfNeeded()
    }
    
    //MARK: TODO VERIFICAR ISTO
    private func initializeSDKIfNeeded() {
        guard sdk == nil else { return }
        
        var cacheOptions: HTTPOptions.CacheOptions?
        if self.settingsService.httpCacheEnabled {
            cacheOptions = HTTPOptions.default.cacheOptions
        } else {
            cacheOptions = nil
        }
        
        let logOptions = LogOptions(
            osLogLevel: self.settingsService.logLevel,
            customLogLevel: self.settingsService.logLevel,
            customSink: nil
        )
        let httpOptions = HTTPOptions(timeout: 15, cacheOptions: cacheOptions)
        let audioOptions = AudioOptions(
            muteOtherSounds: self.settingsService.muteOtherSounds,
            audioVolume: AudioVolume(self.settingsService.navigatorVoiceVolumeSource)
        )
        
        if let apiKeyPath = Bundle.main.path(forResource: "dgissdk", ofType: "key") {
            print("⭐️ apiKeyPath: \(apiKeyPath)")
            let apiKeyOptions = ApiKeyOptions(apiKeyFile: File(path: apiKeyPath))
            sdk = DGis.Container(
                apiKeyOptions: apiKeyOptions,
                logOptions: logOptions,
                httpOptions: httpOptions,
                audioOptions: audioOptions
            )
        } else {
            //DEVOLVER CALLBACK DE ERRO!
            print("🚨 SDK License File not found")
        }
    }


    private var applicationIdleTimerService: IApplicationIdleTimerService {
        UIApplication.shared
    }
    private lazy var settingsStorage: IKeyValueStorage = UserDefaults.standard
    private lazy var navigatorSettings: INavigatorSettings = NavigatorSettings(storage: self.settingsStorage)

    private lazy var settingsService: ISettingsService = {
        let service = SettingsService(
            storage: self.settingsStorage
        )
        service.onCurrentLanguageDidChange = { [weak self] in
            self?.mapFactoryProvider.resetMapFactory()
        }
        service.onMuteOtherSoundsDidChange = { [weak self] value in
            //TESTAR AQUI SE SDK é null e callback se for
            self?.sdk!.audioSettings.muteOtherSounds = value
        }
        service.onNavigatorVoiceVolumeSourceDidChange = { [weak self] value in
            //TESTAR AQUI SE SDK é null e callback se for
            self?.sdk!.audioSettings.audioVolume = value
        }
        return service
    }()

    private lazy var locationGeneratorPositioningQueue: DispatchQueue = DispatchQueue(
        label: "ru.2gis.sdk.app.positioning-queue",
        qos: .default
    )

    //TESTAR AQUI SE SDK é null e callback se for
    private lazy var mapFactoryProvider = MapFactoryProvider(container: self.sdk!, mapGesturesType: .default(.event))

    private lazy var navigationService: NavigationService = NavigationService()

    func makeRootView() -> some View {
        let viewModel = self.makeRootViewModel()
        let viewFactory = self.makeRootViewFactory()
        return RootView(
            viewModel: viewModel,
            viewFactory: viewFactory
        )
        .environmentObject(self.navigationService)
    }

    private func makeRootViewFactory() -> RootViewFactory {
        let viewFactory = RootViewFactory(
            //TESTAR AQUI SE SDK é null e callback se for
            sdk: self.sdk!,
            locationManagerFactory: {
                LocationService()
            },
            settingsService: self.settingsService,
            mapProvider: self.mapFactoryProvider,
            applicationIdleTimerService: self.applicationIdleTimerService,
            navigatorSettings: self.navigatorSettings
        )
        return viewFactory
    }

    private func makeRootViewModel() -> RootViewModel {
        let rootViewModel = RootViewModel(
            demoPages: DemoPage.allCases,
            settingsService: self.settingsService,
            settingsViewModel: SettingsViewModel(
                settingsService: settingsService
            )
        )
        return rootViewModel
    }
    
    // MARK: Map creation methods
    
    func makeSearchStylesDemoPage() -> some View {
        let rootViewFactory = self.makeRootViewFactory()
        let mapFactory = rootViewFactory.makeMapFactory()
        
        // Adds current location to the map
        let source = MyLocationMapObjectSource(
            context: sdk!.context,
            directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
        )
        mapFactory.map.addSource(source: source)
        
        let viewModel = SearchDemoViewModel(
            locationManagerFactory: {LocationService()}, searchManagerFactory: { [sdk = self.sdk] in
                //TESTAR AQUI SE SDK é null e callback se for
                SearchManager.createOnlineManager(context: sdk!.context)
            },
            map: mapFactory.map
        )
        return SearchDemoView(
            viewModel: viewModel,
            viewFactory: rootViewFactory.makeDemoPageComponentsFactory(mapFactory: mapFactory))
    }
}

