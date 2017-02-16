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

**Present the form (Build the `Tyrant::Cotract::ChangePassword`)**
```ruby
def get_new_password
  run Tyrant::GetNewPassword
  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```
Which will show a form with `email`, `password`, `new_password` and `confirm_new_password` with a `Change Password` button.

**Evaluate the form (Build/Validate the `Tyrant::Cotract::ChangePassword`, `policy` check, `change` password)**
```ruby
def change_password
  run Tyrant::ChangePassword do
    flash[:alert] = "The new password has been saved" #flash message
    return redirect_to user_path(tyrant.current_user)
  end

  render cell(Tyrant::Cell::ChangePassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```

Evaluating the form means validate the `TRB::Contract` and apply the `Policy::Guard`, which means verify if:

* all the input are filled
* a User with that `email` exists
* the `password` is correct
* the `new_password` is different than `password`
* the `confirm_new_password` matches `new_password`

In case there is a problem in the inputs an error message is shown otherwise the `TRB::Op` will check the `policy`, therefore in case the email in the form is different than the email in `current_user` the policy will be falsey and you can handle in the way you want. Example:

```ruby
require 'reform/form/dry' 

class User::ChangePassword < Trailblazer::Operation
  step Nested(Tyrant::ChangePassword)
  failure :raise_error!
  step :notify!

  def raise_error!(options, *)
    raise ApplicationController::NotAuthorizedError if options["result.policy.default"].failure?
  end

  def notify!(options, current_user:, **)
    Notification::User.({}, "email" => current_user.email, "type" => "change_password")
  end

end
```
After nesting`Tyrant::ChangePassword` you can create a failure step where in case of a false policy a NotAuthorizedError is raised.

If `validation` and `policy` are satisfied the `new_password` is saved in the User model.

### Reset Password

There is a build-in form to reset the password as well. Here the actions in your controller:

**Present the form (Build the `Tyrant::Cotract::GetEmail`)**
```ruby
def get_email
    run Tyrant::GetEmail
    render cell(Tyrant::Cell::ResetPassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```
Which will show a form with `email` and a `Reset Password` button.

**Evaluate the form (Build/Validate the `Tyrant::Cotract::GetEmail`, generate a random passowrd, update the model and sent an email notification)**
```ruby
def Tyrant::ResetPassword do 
    flash[:alert] = "Your password has been reset" #flash message
    return redirect_to "/sessions/new"
  end

  render cell(Tyrant::Cell::ResetPassword, result["contract.default"], context: {"current_user" => User}, layout: Your::Cell::Layout)
end
```

The contract validation will check if the email is filled and if a the user exists in your database.
In case the validation is satisfied a random 8 characters password is generated and a basic notification email is sent to the User's email.

[Inerithing](http://trailblazer.to/gems/operation/2.0/api.html#inheritance-override) `Tyrant::ResetPassword` allows you to override the `:generate_password!` and `:notify_user!` steps in order to change the way the password is generated and use your own email notification. Example:

```ruby
require 'reform/form/dry' 

class User::ResetPassword < Tyrant::ResetPassword
  step :generate_password!, overide: true
  step :notify_user!, overide: true

  def generate_password!(options, *)
    options["new_password"] = "NewPassword"
  end

  def notify_user!(options, current_user:, **)
    #my notification
    true
  end

end
```

The email notification is sent using [Pony](https://github.com/benprew/pony) gem.
Replace the step or override `email_options!` to set your options and test your code:
```ruby
Tyrant::Mailer.class_eval do 
  def email_options!(options, *)
    Pony.options = {via: :test}
  end  
end
```

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

The forms are presented using formular and bootstrap so this needs to be into an initializer.

```ruby
Formular::Helper.builder= :bootstrap4
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

