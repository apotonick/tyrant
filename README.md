# Tyrant

_"Freedom choked in dread we live, since tyrant was enthroned."_

Tyrant implements all common steps of authorization workflows using overridable _operations_. It allows a quick setup of sign in, sign up, forgot password, etc. Tyrant works well in Rails, but plays well with any Ruby environment.

Operations are provided for the following steps.

* SignIn
  * Confirmed
  * Hammer protection (3x wrong blabla)
  * Sticky (Remember me)
* SignUp
* SignOut
* ResetPassword
* Forgot pw
* Mutiple sessions with scopes


## Operations

trb instead of pushing into controller


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
Tyrant::SignIn.run(params)
```

Tyrant provides forms for all workflow steps. using [Reform](https://github.com/apotonick/reform) objects that are embedded into the operations.


=> Customize with inheritance, or override. Or just don't use the operation and write your own "step".

### Reset Password

Run `Tyrant::ResetPassword.(model: your_user_model)` in order to send a random password to the email saved in the `your_user_model`.
Override `generate_password` to have a different random password generation:
```
Tyrant::ResetPassword.class_eval do 
  def generate_password
    # your code
  end
end
```

The really basic email notification is sent using [Pony](https://github.com/benprew/pony) gem.
Override `email_options` to send your email and test your code:
```
Tyrant::Mailer.class_eval do 
  def email_options
    Pony.options = {via: :test}
  end  
end
```

Override `class Tyrant::Mailer` to have a better looking and not only email notification but remember that we love TRB so it must be a TRB::Operation: `Tyrant::Mailer.(email: model.email, new_password: new_password)`. 


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

