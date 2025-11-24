# TODO: Integrate OpenAI API into Chat Bot

- [ ] Add openai package to pubspec.yaml dependencies
- [ ] Run flutter pub get to install the package
- [ ] Modify lib/chatbot_page.dart to import openai
- [ ] Initialize OpenAI client in initState with base_url and api_key
- [ ] Update _sendMessage method to be async and call OpenAI API for bot responses
- [ ] Build conversation history from _messages for API context
- [ ] Handle API errors gracefully in the chat bot
- [ ] Test the integration by running the app and verifying chat functionality
