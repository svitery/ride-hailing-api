require "dry-validation"

class CreatePaymentMethodSchema < Dry::Validation::Contract
  params do
    required(:tokenized_card).filled(:string)
  end
end
