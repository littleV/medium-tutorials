import React from "react";
import { Button, View, Text, WebView } from "react-native";
import { createStackNavigator, createAppContainer } from "react-navigation";

class HomeScreen extends React.Component {
  render() {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
         <Text>Home Screen</Text>
         <Button
          title="Go to Details"
          onPress={() => this.props.navigation.navigate('Details')}
         />
      </View>
    );
  }
}

class DetailsScreen extends React.Component {
  render() {
    return (
        <WebView
        source={{uri: 'https://www.google.com'}}
        style={{marginTop: 20}}
      />
    );
  }
}

const AppNavigator = createStackNavigator(
  {
    Home: HomeScreen,
    Details: DetailsScreen
  },
  {
    initialRouteName: "Home"
  }
);


export default createAppContainer(AppNavigator);