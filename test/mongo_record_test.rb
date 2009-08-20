$LOAD_PATH[0,0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'test_helper'
require 'active_record'
require 'mongo_record'
Dir[File.join(File.dirname(__FILE__), 'models/*.rb')].each { |f| require f }

class MongoRecordTest < Test::Unit::TestCase

  def setup
    load "#{File.join(File.dirname(__FILE__), 'reload_data.rb')}"
  end

  def test_count
    assert_equal 1, User.count
    assert_equal 3, Product.count
    assert_equal 2, Product.count(:conditions => "title in ('Book 01', 'Book 02')")
    assert_equal 2, Product.count(:all, :conditions => "title in ('Book 01', 'Book 02')")
  end

  def test_count_returns_0_when_collection_does_not_exist
    Order.collection.db.drop_collection('orders')
    assert_equal 0, Order.count

    # Make sure we also return 0 when the collection exists but there are no
    # records.
    Product.delete_all
    assert_equal 0, Product.count
  end

  def test_count_by_sql
    assert_equal 2, Product.count_by_sql("select count(*) from products where title in ('Book 01', 'Book 02')")
    assert_equal 3, Product.count_by_sql("select count(*) from products")
  end

  def test_find
    p = Product.find_by_title('Book 01')
    assert_not_nil p
    assert_equal 'Book 01', p.title
    assert_equal '<p>This is the first book in a series of books.</p>', p.description

    p = Product.find(:first, :conditions => "title = 'Book 01'")
    assert_not_nil p
    assert_equal 'Book 01', p.title

    p = Product.find(:first, :conditions => ["title = ?", 'Book 01'])
    assert_not_nil p
    assert_equal 'Book 01', p.title

    p = Product.find(:first, :conditions => ["title = :title", {:title => 'Book 01'}])
    assert_not_nil p
    assert_equal 'Book 01', p.title

    a = Product.find(:all, :conditions => {:title => ['Book 01']})
    assert_not_nil a
    obj_array = a.to_a
    assert_equal 1, obj_array.length
    assert_not_nil obj_array[0]
    assert_equal 'Book 01', obj_array[0].title

    a = Product.find(:all, :limit => 1)
    assert_equal 1, a.to_a.length
  end

  def test_find_by_id
    p = Product.find(:first, :conditions => "title = 'Book 03'")
    pid = p.id

    p = Product.find(pid)
    assert_not_nil p
    assert_kind_of Product, p
    assert_equal "Book 03", p.title

    # Return a single object when given an array of length one
    p = Product.find([pid])
    assert_not_nil p
    assert_kind_of Product, p
    assert_equal "Book 03", p.title
  end

  def test_sql_like
    a = Product.find(:all, :conditions => "title like 'Book%'")
    assert_not_nil a
    assert_equal 3, a.to_a.length

    a = Product.find(:all, :conditions => "title like '%01'")
    assert_not_nil a
    obj_array = a.to_a
    assert_equal 1, obj_array.length
    assert_equal 'Book 01', obj_array[0].title

    a = Product.find(:all, :conditions => "title like '%k 0%'")
    assert_not_nil a
    assert_equal 3, a.to_a.length

    # Regexes are made case independent
    a = Product.find(:all, :conditions => "title like 'book%'")
    assert_not_nil a
    assert_equal 3, a.to_a.length
  end

  def test_sql_in
    a = Product.find(:all, :conditions => "title in ('Book 01', 'Book 02', 'Book 03')")
    assert_not_nil a
    assert_equal 3, a.to_a.length

    a = Product.find(:all, :conditions => ["title in (?)", ['Book 01', 'Book 02', 'Book 03']])
    assert_not_nil a
    assert_equal 3, a.to_a.length

    a = Product.find(:all, :conditions => ["title in (:titles)", {:titles => ['Book 01', 'Book 02', 'Book 03']}])
    assert_not_nil a
    assert_equal 3, a.to_a.length

    a = Product.find(:all, :conditions => {:title => ['Book 01', 'Book 02', 'Book 03']})
    assert_not_nil a
    assert_equal 3, a.to_a.length

    a = Product.find(:all, :conditions => {:price => (4..6)})
    assert_not_nil a
    assert_equal 3, a.to_a.length
  end

  def test_order_and_limit
    a = Product.find(:all, :order => 'title desc')
    obj_array = a.to_a
    assert_equal 3, obj_array.length
    3.times { |i| assert_equal "Book 0#{3-i}", obj_array[i].title }

    a = Product.find(:all, :order => 'title desc', :limit => 1)
    obj_array = a.to_a
    assert_equal 1, obj_array.length
    p = obj_array[0]
    assert_kind_of Product, p
    assert_equal "Book 03", p.title
  end

  def test_has_many
    o = Order.new
    3.times { |i|
      p = Product.find_by_title("Book 0#{i+1}")
      o.line_items << LineItem.new(:product => p, :quantity => i+1, :total_price => p.price * (i+1))
    }
    o.save

    assert_equal 1, Order.count
    assert_equal 3, LineItem.count
    LineItem.find(:all).each { |li|
      p = li.product
      assert_not_nil p          # make sure line item saved product id properly
      p.title =~ /Book 0(\d)/
      i = $1.to_i               # 1-based
      assert_equal i, li.quantity
      assert_equal li.total_price, p.price * i
    }
  end

  def test_delete
    p = Product.find_by_title('Book 01')
    i = p.id
    Product.delete(p.id)
    assert_equal 2, Product.count
    assert_nil Product.find_by_title('Book 01')
  end

  def test_delete_all
    Product.delete_all("title in ('Book 01', 'Book 02')")
    assert_equal 1, Product.count

    Product.delete_all
    assert_equal 0, Product.count
  end

  def test_increment_decrement_counter
    li = LineItem.new(:quantity => 3, :total_price => 1.5)
    li.save

    LineItem.increment_counter(:quantity, li.id)
    assert_equal 4, LineItem.find(li.id).quantity

    LineItem.decrement_counter(:quantity, li.id)
    assert_equal 3, LineItem.find(li.id).quantity
  end

  def test_columns
    sorted_names = LineItem.columns.collect { |c| c.name }.sort
    assert_equal sorted_names, %w(_id order_id product_id quantity total_price)
  end

  def test_find_by_sql_raises_exception
    begin
      Product.find_by_sql('blargh')
      fail('expected "not implemented" exception')
    rescue => ex
      assert_equal "not implemented", ex.to_s
    end
  end

  def test_update_all_raises_exception
    begin
      Product.update_all('blargh')
      fail('expected "not implemented" exception')
    rescue => ex
      assert_equal "not implemented", ex.to_s
    end
  end

  def test_connection
    c = Product.connection
    assert_not_nil c
    assert_kind_of ActiveRecord::ConnectionAdapters::MongoPseudoConnection, c
  end

  def test_collection
    c = Product.collection
    assert_not_nil c
    assert_kind_of Mongo::Collection, c
    assert_equal 'products', c.name
  end

  def test_collection_info
    ci = Product.collection_info
    assert_not_nil ci
    p = ci['products']
    assert_not_nil p
    assert_kind_of ActiveRecord::ConnectionAdapters::TableDefinition, p
    assert_equal %w(_id description image_url price title), p.columns.collect{|col| col.name}.sort
  end

  def test_update
    User.delete_all

    assert_equal 0, User.count

    u = User.new
    u.name = "foo"
    assert u.save
    oid = u.id

    assert_equal 1, User.count

    u_prime = User.find(:first)
    assert_equal(oid, u_prime.id)
    u_prime.name = "bar"
    assert u_prime.save
    assert_equal(oid, u_prime.id)

    assert_equal 1, User.count

    v = User.find(:first)
    assert_equal(oid, v.id)
    assert_equal "bar", v.name
  end

end
