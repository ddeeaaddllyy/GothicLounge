import SwiftUI

struct TabBarItem: View {
    @State var selectTabView: String
    @State var selectAvatar: String
    @Binding var selected: String
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                selected = selectTabView
            }
        } label : {
            HStack {
                Image(systemName: selectAvatar)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.black)
                if selected == selectTabView {
                    Text(selectTabView)
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }

            }
            .opacity(selected == selectTabView ? 1 : 0.5)
            .padding(.vertical, 5)
            .padding(.horizontal, 20)
            .background(selected == selectTabView ? .white : .gray)
            .clipShape(Capsule())
        }
    }
}
