package no.itszipzon.dto;

/**
 * QuizOptionDto.
 */
public class QuizOptionDto {

  private long id;
  private String option;

  /**
   * QuizOptionDto.
   *
   * @param id id.
   * @param option option.
   * @param correct correct.
   */
  public QuizOptionDto(long id, String option, boolean correct) {
    this.id = id;
    this.option = option;

  }

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  public String getOption() {
    return option;
  }

  public void setOption(String option) {
    this.option = option;
  }

}
