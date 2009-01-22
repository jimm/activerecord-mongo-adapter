LineItem.delete_all
Order.delete_all

User.delete_all
User.create(:name => '10gen', :password => '10gen')

Product.delete_all

Product.create(:title => 'Book 01',
               :description => %{<p>This is the first book in a series of books.</p>},
               :image_url => '/images/book1.jpg',    
               :price => 4)

Product.create(:title => 'Book 02',
               :description => %{<p>This is the second book in a series of books.</p>},
               :image_url => '/images/book2.jpg',    
               :price => 5)

Product.create(:title => 'Book 03',
               :description => %{<p>This is the third book in a series of books.</p>},
               :image_url => '/images/book3.jpg',    
               :price => 6)
