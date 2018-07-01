Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    resources :distribution_centers, only: [:index, :show] do
        resources :inventory, only: [:index, :show] do
			# Reporting routes.
			get 'report', on: :collection, to: 'inventory#report_as_json' # Report as JSON by default.
            get 'report_as_json', on: :collection
			get 'report_as_csv', on: :collection

            # We use patch instead of put because patch is specifically for partial updates.
            # See: http://www.rfc-editor.org/rfc/rfc5789.txt
            patch 'add_to_available_amount', on: :member
            patch 'remove_from_available_amount', on: :member
            patch 'reserve', on: :member
            patch 'move_reserved_back_to_available', on: :member
            patch 'remove_reserved', on: :member
        end
    end

    resources :products, only: [:index, :show] do
    end
end
