module IntVars
  def *(other)
    if other.is_a?(Secret::Variable)
      other * self
    else
      super(other)
    end
  end
end

Integer.class_eval { prepend IntVars }
