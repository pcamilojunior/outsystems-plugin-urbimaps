import SwiftUI

struct SearchDemoView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isPresented: Bool = true
    
    @ObservedObject private var viewModel: SearchDemoViewModel
    private let viewFactory: DemoPageComponentsFactory
    
    @State private var isNavigationSettingsViewPresented = false
    
    init(
        viewModel: SearchDemoViewModel,
        viewFactory: DemoPageComponentsFactory
    ) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
        self.viewModel.showCurrentPosition()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                self.viewFactory.makeMapViewWithZoomControl()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    searchField()
                    
                    categoriesButtons()
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            goToCurrentLocationButton()
                                .padding(.bottom, 10) // Add space between buttons
                            
                            navigationButton()
                                .padding(.bottom, 20)
                        }
                        .padding(.trailing, 20)
                    }
                }
            }
            .navigationBarItems(
                leading: self.backButton()
            )
            .background(Color.clear.edgesIgnoringSafeArea(.all))
       

        }
        .sheet(isPresented: $isNavigationSettingsViewPresented) {
            NavigationSettingsView()
        }
    }
    
    private func searchField() -> some View {
        NavigationLink(destination: self.viewFactory.makeSearchView(searchStore: self.viewModel.searchStore)) {
            HStack {
                if let image = UIImage(named: "neom-logo", in: Bundle.main, compatibleWith: nil) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                } else {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
                Text("Search")
                    .foregroundColor(Color.black.opacity(0.8))
                    .padding(.leading, 8)
                Spacer()
            }
            
            .padding()
            .background(Color(.systemGray6).opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(.systemGray2), lineWidth: 1)
            )
            .cornerRadius(25)
            .padding(.top, 5)
            .padding(.horizontal, 10)
        }
    }
    
    private func categoriesButtons() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryButton(title: "Bars", icon: "wineglass")
                categoryButton(title: "Restaurants", icon: "fork.knife")
                categoryButton(title: "Gas Stations", icon: "car")
                categoryButton(title: "Hotels", icon: "house")
            }
            .padding(.top, 5)
            .padding(.leading, 10)
        }
    }
    
    private func categoryButton(title: String, icon: String) -> some View {
        Button(action: {
            // Add functionality for each button
        }) {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 15, height: 15)
                Text(title)
                    .font(.system(size: 14))
            }
            .padding()
            .foregroundColor(.black)
            .background(Color.white.opacity(0.7))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(.systemGray2), lineWidth: 1)
            )
        }
    }
    
    private func backButton() -> some View {
        Button(action: {
            if #available(iOS 15.0, *) {
                self.presentationMode.wrappedValue.dismiss()
            } else {
                self.isPresented = false
            }
        }) {
            Image(systemName: "chevron.left")
                .scaleEffect(0.63)
                .font(Font.title.weight(.medium))
            Text("Back")
        }
    }
    
    private func goToCurrentLocationButton() -> some View {
        Button(action: {
            self.viewModel.showCurrentPosition()
        }) {
            Image(systemName: "location.fill")
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(50 / 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.systemGray2), lineWidth: 1)
                )
        }
    }
    
    private func navigationButton() -> some View {
        Button(action: {
            self.isNavigationSettingsViewPresented = true
        }) {
            Image(systemName: "arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(50 / 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(.systemGray2), lineWidth: 1)
                )
        }
    }
}
