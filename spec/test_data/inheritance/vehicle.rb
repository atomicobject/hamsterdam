class Vehicle
  construct_with :body, :wheel

  def hit_body
    body.hit
  end

  def hit_wheel
    wheel.hit
  end
end
