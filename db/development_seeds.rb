# frozen_string_literal: true
BODY_PARTS = %w{
  hair
  head
  eyebrow
  eyelash
  eye
  ear
  nose
  nostril
  mouth
  teeth
  tongue
  forearm
  hand
  finger
  fingernail
  thumb
  torso
  buttocks
  leg
  knee
  heal
  foot
  toe
  toenail
}.freeze

PROPERTIES = %w{
  length
  width
  color
  size
}.freeze

100.times do
  Phenotype.create! characteristic: "#{BODY_PARTS.sample} #{PROPERTIES.sample}"
end
