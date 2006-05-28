use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => "Date::JD",
	VERSION_FROM => "lib/Date/JD.pm",
	PREREQ_PM => {
		"Math::BigRat" => "0.04",
	},
);
