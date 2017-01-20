require 'test_helper'

class InstanceTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @instance_type = instance_types(:one)
  end

  test "should get index" do
    get instance_types_url
    assert_response :success
  end

  test "should get new" do
    get new_instance_type_url
    assert_response :success
  end

  test "should create instance_type" do
    assert_difference('InstanceType.count') do
      post instance_types_url, params: { instance_type: { machine_type_id: @instance_type.machine_type_id, os_type: @instance_type.os_type, price: @instance_type.price, price_1y: @instance_type.price_1y, provider_id: @instance_type.provider_id, region_id: @instance_type.region_id } }
    end

    assert_redirected_to instance_type_url(InstanceType.last)
  end

  test "should show instance_type" do
    get instance_type_url(@instance_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_instance_type_url(@instance_type)
    assert_response :success
  end

  test "should update instance_type" do
    patch instance_type_url(@instance_type), params: { instance_type: { machine_type_id: @instance_type.machine_type_id, os_type: @instance_type.os_type, price: @instance_type.price, price_1y: @instance_type.price_1y, provider_id: @instance_type.provider_id, region_id: @instance_type.region_id } }
    assert_redirected_to instance_type_url(@instance_type)
  end

  test "should destroy instance_type" do
    assert_difference('InstanceType.count', -1) do
      delete instance_type_url(@instance_type)
    end

    assert_redirected_to instance_types_url
  end
end
