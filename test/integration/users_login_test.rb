require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    #ログイン用のパスを開く
    get login_path
    #新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'
    #わざと無効なparamsハッシュを使ってセッション用パスにpostする
    post login_path, params: {session: {email: "", password: ""}}
    #新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?
    #別のページに一旦移動する
    get root_path
    #移動先のページでフラッシュメッセージが表示されていないことを確認する    
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    #ログイン用のパスを開く
    get login_path
    #セッション用パスに有効な情報をpostする
    post login_path, params: { session: {email: @user.email,
                                         password: 'password'}}
    #ログイン済みかを確認する
    assert is_logged_in?
    #ログイン用リンクが表示されていることを確認する
    assert_redirected_to @user
    follow_redirect!
    #ログアウト用リンクが表示されていることを確認する
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    #プロフィール用リンクが表示されていることを確認する
    assert_select "a[href=?]", user_path(@user)
    #ログアウトの確認
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    #ログアウト後の画面となっていることを確認する
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
