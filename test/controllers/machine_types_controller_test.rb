require 'test_helper'

class MachineTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @machine_type = machine_types(:one)
  end

  test "should get index" do
    get machine_types_url
    assert_response :success
  end

  test "should get new" do
    get new_machine_type_url
    assert_response :success
  end

  test "should create machine_type" do
    assert_difference('MachineType.count') do
      post machine_types_url, params: { machine_type: { core_count: @machine_type.core_count, memory_size: @machine_type.memory_size, name: @machine_type.name, provider_id: @machine_type.provider_id } }
    end

    assert_redirected_to machine_type_url(MachineType.last)
  end

  test "should show machine_type" do
    get machine_type_url(@machine_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_machine_type_url(@machine_type)
    assert_response :success
  end

  test "should update machine_type" do
    patch machine_type_url(@machine_type), params: { machine_type: { core_count: @machine_type.core_count, memory_size: @machine_type.memory_size, name: @machine_type.name, provider_id: @machine_type.provider_id } }
    assert_redirected_to machine_type_url(@machine_type)
  end

  test "should destroy machine_type" do
    assert_difference('MachineType.count', -1) do
      delete machine_type_url(@machine_type)
    end

    assert_redirected_to machine_types_url
  end
end
