# Tyrant

_"Freedom choked in dread we live, since tyrant was enthroned."_

Tyrant implements all common steps of authorization workflows using overridable _operations_. It allows a quick setup of sign in, sign up, change password, reset password, etc. Tyrant works well in Rails, but plays well with any Ruby environment.

Operations are provided for the following steps.

* SignIn
  * Confirmed
  * Hammer protection (3x wrong blabla)
  * Sticky (Remember me)
* SignUp
* SignOut
* ChangePassword
* ResetPassword
* Mutiple sessions with scopes

## Operations

TRB2 instead of pushing into controller


Tyrant exposes its public API using operations.

Operations are the pivotal element in the [Trailblazer architecture](https://github.com/apotonick/trailblazer). When it comes to customization, Tyrant doesn't rely on a "hopefully complete" configuration language as Devise does it.

Tyrant allows you to customize with Ruby. You can override entire workflow steps (operations), forms and validations (contracts) or methods using simple object-orientation and a clean API.


This means you can easily use them in Rails controllers.

```ruby
class SessionController < ApplicationController
  def sign_in
    run Tyrant::SignIn
  end
```

You can also run the public API in any other Ruby environment, e.g. a console or a Roda action.

```ruby
Tyrant::SignIn.(params)
```

Tyrant provides forms for all workflow steps. using [Reform](https://github.com/apotonick/reform) objects that are embedded into the operations.


=> Customize with inheritance, or override. Or just don't use the operation and write your own "step".

### Change Passowrd

Tyrant provides forms using [Traiblazer::Cells](https://github.com/trailblazer/cells) which means that you don't need to create your own form to get the email, test if the email has a correct format, check if the User exists and bla bla, it's already done here.
Here your 2 methods in your `UserController`:

**Present the form (Build the `TRB::Contract`)**
```ruby
def get_new_password
  run Tyrant::GetNewPassword
  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```
Which will show a form with `email`, `password`, `new_password` and `confirm_new_password` with a `Change Password` button.

**Evaluate the form (Build/Validate the `TRB::Cotract`, `policy` check, `change` password)**
```ruby
def change_password
  run Tyrant::ChangePassword do
    flash[:alert] = "The new password has been saved" #this is just a flash message
    return redirect_to user_path(tyrant.current_user)
  end

  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```

Evaluating the form means first in first build and validate the `TRB::Contract`, which means verify if:

* all the input are filled
* a User with that `email` exists
* the `password` is correct
* the `new_password` is different than `password`
* the `confirm_new_password` matches `new_password`

In case there is a problem in the inputs an error message is shown otherwise the `TRB::Op` will check the `policy`, so in case the email in the form is different than the email in `current_user` the exception `ApplicationController::NotAuthorizedError` is rased, so for example a flash message is shown and the app redirect to `root_path`:

```ruby
class ApplicationController < ActionController::Base
  ..
  ..
  ..

  class NotAuthorizedError < RuntimeError
  end
  
  rescue_from ApplicationController::NotAuthorizedError do |exception|
    flash[:alert] = "You are not authorized!"
    redirect_to rooth_path
  end
```
Using [Dependency injection](http://trailblazer.to/gems/operation/2.0/api.html#dependency-injection) is possible to change how to handle the situation in case the policy is falsey using the "error_handler" key. The only requirement is that you need to pass a callable object so either a method or a Proc, for example:

```rybu
DoSomething = -> {raise MyErrors::ChangePassword}
```
And add the "error_handler" key when you call the operation as at least **second argument (first argument is always `params`)**:
```ruby
Tyrant::ChangePassword.({}, "error_handler" => DoSomething)
```
If everything goes as should go the `new_password` is saved in the User model.

### Reset Password

Reset Password wants as `params` the email of the user and if the validation passes, it will send an email with a new password.
The validations are 

Run `Tyrant::ResetPassword.({email: your_user_email})` after checked that the user exists in your database in order to send a random 8 character password to the email saved in `your_user_model`.
Override `generate_password` to have a different random password generation:
```ruby
Tyrant::ResetPassword.class_eval do 
  def generate_password!(options, *)
    # your code
  end
end
```
Otherwise simply replace the `generate_password!` step in `Tyrant::ResetPassword`.

The really basic email notification is sent using [Pony](https://github.com/benprew/pony) gem.
Replace the step or override `email_options` to set your options and test your code:
```ruby
Tyrant::Mailer.class_eval do 
  def email_options!(options, *)
    Pony.options = {via: :test}
  end  
end
```

Replace the step or override `class Tyrant::Mailer` to have a better looking (and not only) email notification but remember that we love TRB so it must be a `TRB::Operation`: `Tyrant::Mailer.({email: model.email, new_password: new_password})`.

This may be used as `Forgot Password` as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tyrant'
```

## Rails

Tyrant comes with a railtie to provide you an initializer. In Rails, add this to an initializer.

```ruby
require "tyrant/railtie"
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

