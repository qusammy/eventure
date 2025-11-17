import SwiftUI

struct SurveyViewStyleMC: View {
    let question: String
    let answer1: String
    let answer2: String
    let answer3: String
    let answer4: String

    @Binding var selectedAnswer: String

    @State private var answer1Checked = false
    @State private var answer2Checked = false
    @State private var answer3Checked = false
    @State private var answer4Checked = false

    var body: some View {
        VStack {
            Text(question)
                .foregroundStyle(Color("darkColor"))
                .font(Font.custom("UbuntuSans-Regular", size: 20))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 400)

            ForEach(
                [
                    (answer1, $answer1Checked),
                    (answer2, $answer2Checked),
                    (answer3, $answer3Checked),
                    (answer4, $answer4Checked)
                ],
                id: \.0
            ) { answer, isChecked in
                Button {
                    // only one can be checked
                    answer1Checked = (answer == answer1)
                    answer2Checked = (answer == answer2)
                    answer3Checked = (answer == answer3)
                    answer4Checked = (answer == answer4)

                    selectedAnswer = answer
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundStyle(
                                isChecked.wrappedValue
                                ? Color("AccentColor")
                                : Color.white
                            )
                            .opacity(0.80)
                            .frame(maxWidth: 300, minHeight: 50)

                        Text(answer)
                            .foregroundStyle(
                                isChecked.wrappedValue
                                ? Color.white
                                : Color("darkColor")
                            )
                            .font(Font.custom("UbuntuSans-Regular", size: 18))
                            .fontWeight(.medium)
                    }
                }
                .padding(2.5)
            }
        }
    }
}

struct SurveyViewStyleFRQ: View {
    let question: String
    @Binding var userAnswer: String

    var body: some View {
        VStack {
            Text(question)
                .foregroundStyle(Color("darkColor"))
                .font(Font.custom("UbuntuSans-Regular", size: 20))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 400)

            RoundedRectangle(cornerRadius: 15)
                .frame(maxWidth: 300, minHeight: 50)
                .foregroundStyle(Color.white)
                .opacity(0.80)
                .overlay {
                    TextField(
                        "",
                        text: $userAnswer,
                        prompt: Text("e.g. Dallas, TX")
                            .foregroundColor(Color("darkColor"))
                    )
                    .foregroundStyle(Color("darkColor"))
                    .padding(.leading, 5)
                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                    .fontWeight(.medium)
                }
        }
    }
}
