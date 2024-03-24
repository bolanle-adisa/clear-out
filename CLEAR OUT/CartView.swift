//
//  CartView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import Stripe
import StripePaymentSheet

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var paymentSheet: PaymentSheet?
    @State private var showPaymentSheet = false
    @StateObject var backendModel = MyBackendModel()
    @State private var showCheckoutView = false



    var body: some View {
        NavigationView {
            VStack {
                Text("My Cart")
                    .font(.headline)
                    .padding()
                if cartManager.cartItems.isEmpty {
                    Text("Your cart is empty.\nStart shopping now!")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                } else {
                    List {
                        ForEach(cartManager.cartItems) { cartItem in
                            HStack {
                                NavigationLink(destination: ItemCustomerView(item: cartItem.item).environmentObject(cartManager)) {
                                    AsyncImage(url: URL(string: cartItem.item.mediaUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60).cornerRadius(10)
                                        case .failure(_), .empty:
                                            Image(systemName: "photo").frame(width: 60, height: 60).background(Color.gray.opacity(0.1)).cornerRadius(10)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }

                                    VStack(alignment: .leading) {
                                        Text(cartItem.item.name).font(.headline)

                                        // Display the correct price based on sell or rent option
                                        Text("\(cartItem.option == .sell ? "Buy" : "Rent") for $\(cartItem.price, specifier: "%.2f")").font(.subheadline)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Add \(cartItem.item.name) to wishlist")
                                }) {
                                    Image(systemName: "heart").foregroundColor(.red)
                                }
                            }
                        }
                        .onDelete(perform: removeItems)
                    }
                }

                // Calculate subtotal based on cart items and their respective prices
                let subtotal = cartManager.cartItems.reduce(0) { sum, cartItem in
                    sum + cartItem.price
                }

                VStack {
                    HStack {
                        Text("Subtotal:")
                        Spacer()
                        Text("$\(subtotal, specifier: "%.2f")")
                    }
                    .padding()

                    Button(action: {
                        showCheckoutView = true  // Present the CheckoutView
                    }) {
                        Text("Checkout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .contentShape(Rectangle())
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                }
                .background(Color(UIColor.systemBackground))
                .sheet(isPresented: $showCheckoutView) {
                    CheckoutView(backendModel: backendModel).environmentObject(cartManager)
                }
            }
        }
    }

    func removeItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let itemID = cartManager.cartItems[index].item.id ?? ""
            cartManager.removeFromCart(itemID: itemID)
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView().environmentObject(CartManager.shared)
    }
}
