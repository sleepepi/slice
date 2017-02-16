# frozen_string_literal: true

require 'pats/categories/default'
require 'pats/categories/gender/female'
require 'pats/categories/gender/male'
require 'pats/categories/gender/unknown'
require 'pats/categories/race/all'
require 'pats/categories/age/three_to_four'
require 'pats/categories/age/five_to_six'
require 'pats/categories/age/seven_plus'
require 'pats/categories/age/unknown'
require 'pats/categories/ethnicity/hispanic'
require 'pats/categories/ethnicity/not_hispanic'
require 'pats/categories/ethnicity/unknown'
require 'pats/categories/eligibility/caregiver_not_interested'
require 'pats/categories/eligibility/fully_eligible'
require 'pats/categories/eligibility/ineligible'
require 'pats/categories/eligibility/unknown'
require 'pats/categories/screen_failures/all'
require 'pats/categories/disinterested/all'
require 'pats/categories/ent_failures/all'
require 'pats/categories/psg_failures/all'
require 'pats/categories/psg_overall_study_qualities/all'
require 'pats/categories/signal_quality_grades/all'

module Pats
  # Defines categories of variables.
  module Categories
    DEFAULT_CATEGORY = Pats::Categories::Default
    CATEGORIES = {
      'female' => Pats::Categories::Gender::Female,
      'male' => Pats::Categories::Gender::Male,
      'gender-unknown' => Pats::Categories::Gender::Unknown,
      'black-race' => Pats::Categories::Race::Black,
      'white-race' => Pats::Categories::Race::White,
      'american-indian-race' => Pats::Categories::Race::AmericanIndian,
      'asian-race' => Pats::Categories::Race::Asian,
      'hawaiian-race' => Pats::Categories::Race::Hawaiian,
      'multiple-race' => Pats::Categories::Race::Multiple,
      'unknown-race' => Pats::Categories::Race::Unknown,
      'age-3to4' => Pats::Categories::Age::ThreeToFour,
      'age-5to6' => Pats::Categories::Age::FiveToSix,
      'age-7plus' => Pats::Categories::Age::SevenPlus,
      'age-unknown' => Pats::Categories::Age::Unknown,
      'hispanic' => Pats::Categories::Ethnicity::Hispanic,
      'not-hispanic' => Pats::Categories::Ethnicity::NotHispanic,
      'ethnicity-unknown' => Pats::Categories::Ethnicity::Unknown,
      'fully-eligible' => Pats::Categories::Eligibility::FullyEligible,
      'ineligible' => Pats::Categories::Eligibility::Ineligible,
      'caregiver-not-interested' => Pats::Categories::Eligibility::CaregiverNotInterested,
      'eligibility-unknown' => Pats::Categories::Eligibility::Unknown,
      'prev-upper-airway-surgery' => Pats::Categories::ScreenFailures::PrevUpperAirwaySurgery,
      'dx-chronic-prob' => Pats::Categories::ScreenFailures::DxChronicProb,
      'recurrent-tonsillitis' => Pats::Categories::ScreenFailures::RecurrentTonsillitis,
      'hx-psych-behavioral-disorder' => Pats::Categories::ScreenFailures::HxPsychBehavioralDisorder,
      'known-cond-airway' => Pats::Categories::ScreenFailures::KnownCondAirway,
      'taking-meds' => Pats::Categories::ScreenFailures::TakingMeds,
      'ent-eligibility-not-met' => Pats::Categories::ScreenFailures::EntEligibilityNotMet,
      'parent-report-snoring' => Pats::Categories::ScreenFailures::ParentReportSnoring,
      'previous-osa-diagnosis' => Pats::Categories::ScreenFailures::PreviousOSADiagnosis,
      'psg-eligibility-not-met' => Pats::Categories::ScreenFailures::PsgEligibilityNotMet,
      'bmi-z-score-le3' => Pats::Categories::ScreenFailures::BmiZScoreLe3,
      'caregiver-understand-english' => Pats::Categories::ScreenFailures::CaregiverUnderstandEnglish,
      'moving-in-year' => Pats::Categories::ScreenFailures::MovingInYear,
      'foster-care' => Pats::Categories::ScreenFailures::FosterCare,
      'time-commitment-too-great' => Pats::Categories::Disinterested::TimeCommitmentTooGreat,
      'too-difficult-traveling-to-appointments' => Pats::Categories::Disinterested::TooDifficultTravelingToAppointments,
      'study-compensation-too-low' => Pats::Categories::Disinterested::StudyCompensationTooLow,
      'not-comfortable-with-randomization' => Pats::Categories::Disinterested::NotComfortableWithRandomization,
      'unable-to-complete-screening-psg' => Pats::Categories::Disinterested::UnableToCompleteScreeningPsg,
      'unable-to-complete-ent-evaluation' => Pats::Categories::Disinterested::UnableToCompleteEntEvaluation,
      'unable-to-complete-other-testing' => Pats::Categories::Disinterested::UnableToCompleteOtherTesting,
      'child-does-not-want-to-enroll' => Pats::Categories::Disinterested::ChildDoesNotWantToEnroll,
      'caregiver-could-not-be-contacted-for-eligibility' => Pats::Categories::Disinterested::CaregiverCouldNotBeContactedForEligibility,
      'caregiver-no-showed-for-visit-and-cannot-be-contacted' => Pats::Categories::Disinterested::CaregiverNoShowedForVisitAndCannotBeContacted,
      'caregiver-not-interested-other-reasons' => Pats::Categories::Disinterested::OtherReasons,
      'disinterest-reason-unknown' => Pats::Categories::Disinterested::ReasonUnknown,
      'ent-eligibility-failure-1' => Pats::Categories::ENTFailures::ENTEligibility1,
      'ent-eligibility-failure-2' => Pats::Categories::ENTFailures::ENTEligibility2,
      'ent-eligibility-failure-3' => Pats::Categories::ENTFailures::ENTEligibility3,
      'ent-eligibility-failure-4' => Pats::Categories::ENTFailures::ENTEligibility4,
      'ent-eligibility-failure-5' => Pats::Categories::ENTFailures::ENTEligibility5,
      'ent-eligibility-failure-6' => Pats::Categories::ENTFailures::ENTEligibility6,
      'psg-eligibility-failure-1' => Pats::Categories::PSGFailures::PSGEligibility1,
      'psg-eligibility-failure-2' => Pats::Categories::PSGFailures::PSGEligibility2,
      'psg-eligibility-failure-3' => Pats::Categories::PSGFailures::PSGEligibility3,
      'psg-eligibility-failure-4' => Pats::Categories::PSGFailures::PSGEligibility4,
      'psg-5-outstanding' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality5,
      'psg-4-excellent' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality4,
      'psg-3-very-good' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality3,
      'psg-2-good' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality2,
      'psg-1-fair' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality1,
      'psg-98-other' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality98,
      'psg-0-failed' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQuality0,
      'psg-unknown' => Pats::Categories::PSGOverallStudyQualities::PSGOverallStudyQualityUnknown,
      'psg-e1-signal-quality-grade' => Pats::Categories::SignalQualityGrades::PSGE1SignalQualityGrade,
      'psg-chest-signal-quality-grade' => Pats::Categories::SignalQualityGrades::PSGChestSignalQualityGrade,
      'psg-cap-signal-quality-grade' => Pats::Categories::SignalQualityGrades::PSGCapSignalQualityGrade,
      'psg-snore-signal-quality-grade' => Pats::Categories::SignalQualityGrades::PSGSnoreSignalQualityGrade
    }

    def self.for(category, project)
      (CATEGORIES[category] || DEFAULT_CATEGORY).new(project)
    end
  end
end
