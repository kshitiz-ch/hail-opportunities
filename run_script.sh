#!/bin/bash


buildRunner(){
    flutter pub run build_runner build --delete-conflicting-outputs
    # cd ./lib/src/config/routes
    # sed 's/?//g' router.gr.dart > new.dart && mv new.dart router.gr.dart
    # cd -
}


runApp(){
cd api_sdk
echo "+++++API SDK pub clean+++++"
flutter clean
echo "+++++API SDK pub get+++++"
flutter pub get
echo "+++++API SDK done+++++"


cd ../core
echo "+++++core pub clean+++++"
flutter clean
echo "+++++core pub get+++++"
flutter pub get
echo "+++++core done+++++"

cd ../app
echo "+++++Main app pub clean+++++"
flutter clean
echo "+++++Main app pub get+++++"
flutter pub get
echo "+++++build Runner+++++"
buildRunner
echo "+++++Main app run+++++"

 if [ $# -gt 0 ] 
    then
        case $1 in

            "prod")
                echo  "Running prod "
                flutter run --flavor prod -t lib/main-prod.dart
                ;;

            "dev")
                echo  "Running dev "
                flutter run --flavor dev -t lib/main-dev.dart
                ;;

            *)
                echo  "Running dev "
                flutter run --flavor dev -t lib/main-dev.dart
                ;;
        esac
 else
    echo  "Running dev"
    flutter run --flavor dev -t lib/main-dev.dart
 fi
}

runApp "$@"
