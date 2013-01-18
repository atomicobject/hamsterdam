class Malibu < Car
  construct_with :body, :wheel, :emblem

  def hit_emblem
    emblem.hit
  end
end
