/// To prevent confusion in the useCase we created an abstract class
/// In dart if we create a call function inside the abstract or concrete(non
/// abstract) class . when ever we create an object with constructor it will
/// automatically call. Here we have `Type` that is gonna return Data,  and `Params` which
/// we gonna pass through the function we should add in the generic form(<>),
///
abstract class UseCase<Type, Params> {
  /// In the `call()` method we get the data from the repository
  Future<Type> call({Params params});
}
