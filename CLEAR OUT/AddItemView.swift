//
//  AddItemView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

struct AddItemView: View {
    @Binding var itemsForSaleAndRent: [ItemForSaleAndRent]
    @Environment(\.presentationMode) var presentationMode

    @State private var itemName: String = ""
    @State private var itemDescription: String = ""
    @State private var itemPrice: String = ""
    @State private var rentPrice: String = ""
    @State private var rentPeriod: String = "1 day"
    @State private var selectedSize: String = ""
    @State private var isPresentingMediaPicker = false
    @State private var inputImage: UIImage?
    @State private var itemImage: Image?
    @State private var selectedCategory: String = ""
    @State private var showActionSheet = false
    @State private var showingSourcePicker = false
    @State private var videoURL: URL?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedColorIndex = 0





    let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
    let categories = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes","Electronics", "Dorm Essentials", "Books" ]
    let currencyFormatter = NumberFormatter.currencyFormatter()
    let rentPeriodOptions = ["1 day", "1 week", "2 weeks", "1 month"]

    var body: some View {
            NavigationView {
                Form {
                    itemImageSection
                    itemNameSection
                    itemDescriptionSection
                    categorySection
                    itemPriceSection
                    rentOptionsSection
                    itemSizeSection
                    itemColorSection
                }
                .navigationTitle("Add New Item")
                .navigationBarItems(trailing: Button("Done") {
                    addNewItem()
                }.disabled(isFormInvalid))
                .sheet(isPresented: $isPresentingMediaPicker) {
                    UniversalMediaPickerView(inputImage: $inputImage, videoURL: $videoURL, completion: handleMediaSelection, sourceType: sourceType)
                }
            }
        }
    
    var isFormInvalid: Bool {
            let hasMedia = inputImage != nil || videoURL != nil
            let hasRequiredTextFieldsFilled = !itemName.isEmpty && !selectedCategory.isEmpty && !selectedSize.isEmpty
            let hasSaleOrRentalInfo = !itemPrice.isEmpty || (!rentPrice.isEmpty && !rentPeriod.isEmpty)
            
            return !(hasMedia && hasRequiredTextFieldsFilled && hasSaleOrRentalInfo)
        }

        private var rentOptionsSection: some View {
            let isRentalDisabled = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes"].contains(selectedCategory)
            
            return Section(header: Text("Rental Options")) {
                HStack {
                    Text(currencyFormatter.currencySymbol)
                        .foregroundColor(.gray)
                    TextField("Enter Rental Price", text: $rentPrice)
                        .keyboardType(.decimalPad)
                        .disabled(isRentalDisabled)
                }
                Picker("Select Rental Period", selection: $rentPeriod) {
                    ForEach(rentPeriodOptions, id: \.self) {
                        Text($0)
                    }
                }
                .disabled(isRentalDisabled)
            }
        }

    private func handleMediaSelection() {
        if let selectedImage = inputImage {
            // An image was selected
            itemImage = Image(uiImage: selectedImage)
        } else if let selectedVideoURL = videoURL {
            // A video was selected, generate a thumbnail
            if let thumbnail = generateThumbnail(for: selectedVideoURL) {
                itemImage = Image(uiImage: thumbnail)
            } else {
                // Fallback if thumbnail generation fails
                itemImage = Image(systemName: "video.fill")
            }
        }
    }

    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }


    private func addNewItem() {
        guard !itemName.isEmpty, !selectedCategory.isEmpty, (inputImage != nil || videoURL != nil) else {
            print("Validation failed")
            return
        }

        let completion: (Result<URL, Error>) -> Void = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.createItemWithMedia(url: url.absoluteString, isVideo: self.videoURL != nil)
                case .failure(let error):
                    print("Upload error: \(error.localizedDescription)")
                }
            }
        }

        if let inputImage = self.inputImage {
            FirebaseStorageManager.shared.uploadImageToStorage(inputImage, completion: completion)
        } else if let videoURL = self.videoURL {
            FirebaseStorageManager.shared.uploadVideoToStorage(videoURL, completion: completion)
        }
    }

    private func createItemWithMedia(url: String, isVideo: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let salePrice = !itemPrice.isEmpty ? Double(itemPrice) ?? 0.0 : 0.0
        let isRentalDisabled = ["Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes"].contains(selectedCategory)
        let rentalPrice = !isRentalDisabled && !rentPrice.isEmpty ? Double(rentPrice) ?? 0.0 : 0.0
        let rentalPeriod = !isRentalDisabled && !rentPeriod.isEmpty ? rentPeriod : "Not Applicable"

        var data: [String: Any] = [
            "userId": userId,
            "name": itemName,
            "description": itemDescription,
            "mediaUrl": url,
            "isVideo": isVideo,
            "timestamp": FieldValue.serverTimestamp(),
            "price": salePrice,
            "rentPrice": rentalPrice,
            "rentPeriod": rentalPeriod,
            "size": selectedSize,
            "color": colorChoices[selectedColorIndex].name // Assuming colorChoices is an array of some color structure
        ]

        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Item successfully added to Firestore.")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("DidAddNewItem"), object: nil)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    
    private var itemImageSection: some View {
        Section(header: Text("Item Image")) {
            Button(action: {
                showingSourcePicker = true
            }) {
                ZStack {
                    if let itemImage = itemImage {
                        itemImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 180) // Larger frame for selected image or video placeholder
                    } else {
                        // Smaller representation for the add button
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 20)) // Adjusted for smaller representation
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding() // Add padding to match the height of text fields
                        .background(Rectangle().fill(Color.clear)) // Keep clear background
                        .frame(height: 44) // Match the height of text input fields
                    }
                }
            }
        }
        .actionSheet(isPresented: $showingSourcePicker) {
            ActionSheet(title: Text("Select Media"), message: Text("Choose a source"), buttons: [
                .default(Text("Camera")) {
                    self.sourceType = .camera
                    self.isPresentingMediaPicker = true
                },
                .default(Text("Photo Library")) {
                    self.sourceType = .photoLibrary
                    self.isPresentingMediaPicker = true
                },
                .cancel()
            ])
        }
    }

    private var itemNameSection: some View {
            Section(header: Text("Item Name")) {
                TextField("Enter item name", text: $itemName)
            }
        }

    private var itemDescriptionSection: some View {
        Section(header: Text("Description")) {
            TextField("Enter description", text: $itemDescription)
        }
    }

    private var categorySection: some View {
        Section(header: Text("Category")) {
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for compact presentation
        }
    }
    
    private var itemPriceSection: some View {
        Section(header: Text("Sale Option")) {
            HStack {
                Text(currencyFormatter.currencySymbol)
                    .foregroundColor(.gray)
                TextField("Enter Sale price", text: $itemPrice)
                    .keyboardType(.decimalPad)
                    .onReceive(itemPrice.publisher.collect()) {
                        self.itemPrice = String($0.prefix(10)).filter { "0123456789.".contains($0) }
                    }
            }
        }
    }

        private var itemSizeSection: some View {
            Section(header: Text("Size")) {
                Picker("Select size", selection: $selectedSize) {
                    ForEach(sizes, id: \.self) { size in
                        Text(size).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }

    private var itemColorSection: some View {
            Section(header: Text("Color")) {
                Picker("Select color", selection: $selectedColorIndex) {
                    ForEach(colorChoices.indices, id: \.self) { index in
                        HStack {
                            colorChoices[index].color
                                .frame(width: 20, height: 20)
                                .cornerRadius(10)
                            Text(colorChoices[index].name)
                        }
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
        }


    private var addItemButtonSection: some View {
        Section {
            Button("Add Item") {
                // Ensure required fields are filled
                guard !itemName.isEmpty, let price = Double(itemPrice), !selectedSize.isEmpty, !selectedCategory.isEmpty else { return }
                
                // Handle image upload if present
                if let inputImage = self.inputImage {
                    FirebaseStorageManager.shared.uploadImageToStorage(inputImage) { result in
                        switch result {
                        case .success(let url):
                            self.createItemWithMedia(url: url.absoluteString, isVideo: false)
                        case .failure(let error):
                            print("Image upload error: \(error.localizedDescription)")
                        }
                    }
                }
                
                // Handle video upload if present
                if let videoURL = self.videoURL {
                    FirebaseStorageManager.shared.uploadVideoToStorage(videoURL) { result in
                        switch result {
                        case .success(let url):
                            self.createItemWithMedia(url: url.absoluteString, isVideo: true)
                        case .failure(let error):
                            print("Video upload error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .disabled(itemName.isEmpty || itemPrice.isEmpty || selectedSize.isEmpty || selectedCategory.isEmpty || (inputImage == nil && videoURL == nil))
        }
    }

    
func loadImage() {
    guard let inputImage = inputImage else { return }
    itemImage = Image(uiImage: inputImage)
    }
}

extension NumberFormatter {
    static func currencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current // Adjusts currency symbol based on user's local
        return formatter
    }
}


struct CurrencyInputField: View {
    @Binding var value: Double?
    var formatter: NumberFormatter

    var body: some View {
        HStack {
            Text(formatter.currencySymbol)
            TextField("Amount", value: $value, formatter: formatter)
                .keyboardType(.decimalPad)
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        AddItemView(itemsForSaleAndRent: .constant([]))
    }
}
